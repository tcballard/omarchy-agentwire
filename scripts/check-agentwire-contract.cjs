const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

const pluginRoot = path.join(__dirname, "..")
const source = fs.readFileSync(path.join(pluginRoot, "Model.js"), "utf8").replace(/^\.pragma library\s*/m, "")
const Model = { isFinite, Math, Number, String }
vm.createContext(Model)
vm.runInContext(source, Model)

const golden = JSON.parse(fs.readFileSync(process.argv[2], "utf8"))
const parsed = Model.parseSummary(golden)
assert.equal(parsed.ok, true, parsed.message)
assert.equal(parsed.state, "recording")
assert.equal(parsed.summary.events, golden.events)
assert.equal(parsed.summary.lastMethod, golden.last_method)
console.log("AgentWire inspector-summary-v1 contract: ok")

