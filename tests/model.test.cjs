const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const test = require("node:test")
const vm = require("node:vm")

const root = path.join(__dirname, "..")
const source = fs.readFileSync(path.join(root, "Model.js"), "utf8").replace(/^\.pragma library\s*/m, "")
const Model = { console, isFinite, Math, Number, String }
vm.createContext(Model)
vm.runInContext(source, Model)
const fixture = name => JSON.parse(fs.readFileSync(path.join(__dirname, "fixtures", name + ".json"), "utf8"))

test("parses a live v1 summary", () => {
  const result = Model.parseSummary(fixture("live"))
  assert.equal(result.ok, true)
  assert.equal(result.state, "recording")
  assert.equal(result.summary.events, 11)
})

test("parses a completed signed exit", () => {
  const result = Model.parseSummary(fixture("completed"))
  assert.equal(result.state, "completed")
  assert.equal(result.summary.exitCode, -9)
})

test("served incomplete traces are inactive", () => {
  const result = Model.parseSummary(fixture("incomplete"))
  assert.equal(result.state, "served")
  assert.equal(result.summary.active, false)
})

test("rejects incompatible API versions", () => {
  const value = fixture("live"); value.api_version = 2
  assert.equal(Model.parseSummary(value).state, "incompatible")
})

test("rejects inconsistent lifecycle fields", () => {
  const value = fixture("live"); value.active = false
  assert.equal(Model.parseSummary(value).ok, false)
})

test("rejects negative and fractional counts", () => {
  const negative = fixture("live"); negative.events = -1
  const fractional = fixture("live"); fractional.errors = 0.5
  assert.equal(Model.parseSummary(negative).ok, false)
  assert.equal(Model.parseSummary(fractional).ok, false)
})

test("enforces signed 32-bit exit codes", () => {
  const value = fixture("completed"); value.exit_code = 2147483648
  assert.equal(Model.parseSummary(value).ok, false)
})

test("accepts only numeric loopback inspector URLs", () => {
  assert.equal(Model.normalizeInspectorUrl("HTTP://127.0.0.1:04777/"), "http://127.0.0.1:4777")
  assert.equal(Model.normalizeInspectorUrl("http://[::1]:4777"), "http://[::1]:4777")
  assert.equal(Model.normalizeInspectorUrl("http://localhost:4777"), "")
  assert.equal(Model.normalizeInspectorUrl("https://127.0.0.1:4777"), "")
  assert.equal(Model.normalizeInspectorUrl("http://127.0.0.1:0"), "")
})

test("builds the summary endpoint", () => {
  assert.equal(Model.summaryUrl("http://127.0.0.1:4777"), "http://127.0.0.1:4777/api/summary")
})

test("requires the exact final response URL", () => {
  assert.equal(Model.responseUrlMatches("http://127.0.0.1:4777", "http://127.0.0.1:4777/api/summary"), true)
  assert.equal(Model.responseUrlMatches("http://127.0.0.1:4777", "http://127.0.0.2:4777/api/summary"), false)
})

test("accepts JSON media types with parameters", () => {
  assert.equal(Model.isJsonContentType("application/json; charset=utf-8"), true)
  assert.equal(Model.isJsonContentType("text/json"), false)
})

test("poll backoff is bounded", () => {
  assert.equal(Model.nextPollDelay(2000, 0), 2000)
  assert.equal(Model.nextPollDelay(2000, 2), 8000)
  assert.equal(Model.nextPollDelay(2000, 30), 30000)
})

test("formats durations and status without markup", () => {
  assert.equal(Model.durationLabel(1240), "1.2 s")
  assert.equal(Model.statusLabel("completed", { exitCode: 3 }), "Completed · exit 3")
})

test("provides explicit Codex, ACP, and MCP recording recipes", () => {
  assert.deepEqual({ ...Model.recordingRecipe("codex") }, {
    key: "codex", label: "Codex App Server", target: "codex app-server", shortcut: "C"
  })
  assert.equal(Model.recordingRecipe("acp").target, "YOUR_ACP_AGENT")
  assert.equal(Model.recordingRecipe("mcp").target, "YOUR_MCP_SERVER")
  assert.equal(Model.recordingRecipe("unknown"), null)
})
