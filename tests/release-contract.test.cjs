const assert = require("node:assert/strict")
const crypto = require("node:crypto")
const childProcess = require("node:child_process")
const fs = require("node:fs")
const os = require("node:os")
const path = require("node:path")
const test = require("node:test")

const root = path.join(__dirname, "..")
const read = file => fs.readFileSync(path.join(root, file), "utf8")

test("manifest exposes native service and bar entry points", () => {
  const manifest = JSON.parse(read("manifest.json"))
  assert.equal(manifest.schemaVersion, 1)
  assert.equal(manifest.version, "0.2.0")
  assert.deepEqual(manifest.kinds, ["service", "bar-widget"])
  assert.deepEqual(manifest.entryPoints, { service: "Service.qml", barWidget: "Panel.qml" })
  assert.equal(fs.existsSync(path.join(root, "BarWidget.qml")), false)
  assert.equal(fs.existsSync(path.join(root, "Service.qml")), true)
  assert.equal(fs.existsSync(path.join(root, "bin/agentwire")), true)
  assert.equal(fs.statSync(path.join(root, "bin/agentwire")).mode & 0o111, 0o111)
  assert.equal(fs.statSync(path.join(root, "bin/agentwire-x86_64")).mode & 0o111, 0o111)
})

test("service owns the fixed loopback hub without user configuration", () => {
  const service = read("Service.qml")
  const panel = read("Panel.qml")
  const manifest = JSON.parse(read("manifest.json"))
  assert.match(service, /XDG_RUNTIME_DIR/)
  assert.match(service, /127\.0\.0\.1:4777/)
  assert.match(service, /\/bin\/agentwire/)
  assert.match(panel, /readonly property string inspectorUrl: "http:\/\/127\.0\.0\.1:4777"/)
  assert.equal("inspectorUrl" in manifest.barWidget.defaults, false)
  assert.equal(manifest.barWidget.schema.some(field => field.key === "inspectorUrl"), false)
})

test("bundled runtime matches its committed checksum", () => {
  const binary = fs.readFileSync(path.join(root, "bin/agentwire-x86_64"))
  const expected = read("bin/agentwire-x86_64.sha256").trim().split(/\s+/)[0]
  assert.equal(crypto.createHash("sha256").update(binary).digest("hex"), expected)
  assert.match(childProcess.execFileSync(path.join(root, "bin/agentwire-x86_64"), ["--version"], { encoding: "utf8" }), /^agentwire 0\.1\.0\s*$/)
})

test("native launcher supplies private state without changing wrapped commands", () => {
  const fixture = fs.mkdtempSync(path.join(os.tmpdir(), "agentwire-launcher-"))
  try {
    const bin = path.join(fixture, "bin")
    const runtime = path.join(fixture, "runtime")
    const state = path.join(fixture, "state")
    const capture = path.join(fixture, "arguments")
    fs.mkdirSync(bin)
    fs.copyFileSync(path.join(root, "bin/agentwire"), path.join(bin, "agentwire"))
    fs.chmodSync(path.join(bin, "agentwire"), 0o755)
    fs.writeFileSync(path.join(bin, "agentwire-x86_64"), "#!/usr/bin/env bash\nprintf '%s\\n' \"$@\" >\"$CAPTURE\"\n")
    fs.chmodSync(path.join(bin, "agentwire-x86_64"), 0o755)
    fs.mkdirSync(runtime)
    const env = { ...process.env, CAPTURE: capture, HOME: fixture, XDG_RUNTIME_DIR: runtime, XDG_STATE_HOME: state }

    childProcess.execFileSync(path.join(bin, "agentwire"), ["hub", "--listen", "127.0.0.1:4777"], { env })
    assert.deepEqual(fs.readFileSync(capture, "utf8").trim().split("\n"), [
      "hub", "--state", path.join(runtime, "agentwire/inspector.json"), "--listen", "127.0.0.1:4777"
    ])

    childProcess.execFileSync(path.join(bin, "agentwire"), ["record", "--protocol", "acp", "--", "/bin/true", "--trace"], { env })
    const generated = fs.readFileSync(capture, "utf8").trim().split("\n")
    assert.deepEqual(generated.slice(0, 3), ["record", "--publish-summary", path.join(runtime, "agentwire/inspector.json")])
    assert.equal(generated[3], "--trace")
    assert.match(generated[4], new RegExp(`^${state.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}/agentwire/traces/agentwire-`))
    assert.deepEqual(generated.slice(5), ["--protocol", "acp", "--", "/bin/true", "--trace"])

    const explicit = path.join(fixture, "chosen.jsonl")
    childProcess.execFileSync(path.join(bin, "agentwire"), ["record", `--trace=${explicit}`, "--", "/bin/true"], { env })
    const preserved = fs.readFileSync(capture, "utf8").trim().split("\n")
    assert.equal(preserved.filter(argument => argument === "--trace" || argument.startsWith("--trace=")).length, 1)
    assert.equal(preserved.includes(`--trace=${explicit}`), true)

    const blocked = childProcess.spawnSync(path.join(bin, "agentwire"), ["record", "--ui", "--", "/bin/true"], { env, encoding: "utf8" })
    assert.equal(blocked.status, 64)
    assert.match(blocked.stderr, /plugin owns AgentWire's inspector hub/)
  } finally {
    fs.rmSync(fixture, { recursive: true, force: true })
  }
})

test("poller carries the response and lifecycle guards", () => {
  const panel = read("Panel.qml")
  for (const marker of ["MAX_RESPONSE_CHARS", "responseURL", "Content-Type", "requestSerial", "requestTimeout", "HEADERS_RECEIVED", "LOADING", "DONE"])
    assert.match(panel, new RegExp(marker))
  assert.ok(panel.indexOf("body.length > Model.MAX_RESPONSE_CHARS") < panel.indexOf("request.status === 0"))
  for (const state of ["recording", "served", "completed", "limited", "unavailable", "incompatible", "misconfigured", "offline", "connecting"])
    assert.ok(read("Model.js").includes(`\"${state}\"`) || panel.includes(`\"${state}\"`))
})

test("release pins and workflows are immutable", () => {
  const revisions = read("scripts/contract-revisions.sh")
  assert.match(revisions, /OMARCHY_REVISION=[0-9a-f]{40}/)
  assert.match(revisions, /AGENTWIRE_REVISION=[0-9a-f]{40}/)
  assert.match(revisions, /AGENTWIRE_RUST_TOOLCHAIN=1\.98\.0/)
  assert.equal(fs.existsSync(path.join(root, ".github/workflows/ci.yml")), true)
  assert.equal(fs.existsSync(path.join(root, ".github/workflows/release.yml")), true)
  assert.match(read(".github/workflows/ci.yml"), /AGENTWIRE_VERIFY_BUNDLE: 1/)
  assert.match(read(".github/workflows/release.yml"), /AGENTWIRE_VERIFY_BUNDLE: 1/)
  assert.match(read(".gitattributes"), /^\.github export-ignore/m)
  assert.match(read(".gitattributes"), /^launch-pack export-ignore/m)
})
