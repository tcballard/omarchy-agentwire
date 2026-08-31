const fs = require("node:fs")
const path = require("node:path")

const source = fs.readFileSync(path.join(__dirname, "..", "Panel.qml"), "utf8")
const starts = [...source.matchAll(/\bText\s*\{/g)].map(match => match.index)
for (const start of starts) {
  let depth = 0, end = start
  for (; end < source.length; end++) {
    if (source[end] === "{") depth++
    if (source[end] === "}" && --depth === 0) break
  }
  if (!/textFormat\s*:\s*Text\.PlainText/.test(source.slice(start, end + 1))) {
    console.error(`Text block at offset ${start} does not force Text.PlainText`)
    process.exit(1)
  }
}
console.log(`dynamic text safety: ${starts.length} Text blocks use Text.PlainText`)
