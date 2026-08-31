const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const test = require("node:test")

const root = path.join(__dirname, "..")
const read = file => fs.readFileSync(path.join(root, file), "utf8")

test("manifest exposes one Quattro-native v0.2.0 entry point", () => {
  const manifest = JSON.parse(read("manifest.json"))
  assert.equal(manifest.schemaVersion, 1)
  assert.equal(manifest.version, "0.2.0")
  assert.deepEqual(manifest.entryPoints, { barWidget: "Panel.qml" })
  assert.equal(fs.existsSync(path.join(root, "BarWidget.qml")), false)
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
  assert.equal(fs.existsSync(path.join(root, ".github/workflows/ci.yml")), true)
  assert.equal(fs.existsSync(path.join(root, ".github/workflows/release.yml")), true)
  assert.match(read(".gitattributes"), /^\.github export-ignore/m)
  assert.match(read(".gitattributes"), /^launch-pack export-ignore/m)
})
