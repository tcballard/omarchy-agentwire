.pragma library

var API_VERSION = 1
var TRACE_VERSION = 1
var MAX_RESPONSE_CHARS = 65536
var MAX_BACKOFF_MS = 30000

function emptySummary() {
  return { apiVersion: API_VERSION, traceVersion: TRACE_VERSION, mode: "", active: false,
    sessionId: "", startedAt: "", ended: false, exitCode: null, events: 0,
    durationMs: 0, clientMessages: 0, serverMessages: 0, invalidMessages: 0,
    errors: 0, lastMethod: "" }
}

function integerInRange(value, minimum, maximum) {
  return typeof value === "number" && isFinite(value) && Math.floor(value) === value
    && value >= minimum && value <= maximum
}

function parseSummary(value) {
  if (!value || typeof value !== "object" || value instanceof Array)
    return { ok: false, state: "unavailable", message: "Invalid summary" }
  if (value.api_version !== API_VERSION || value.trace_version !== TRACE_VERSION)
    return { ok: false, state: "incompatible", message: "Unsupported AgentWire API" }
  if (value.mode !== "live_record" && value.mode !== "served_trace")
    return { ok: false, state: "unavailable", message: "Invalid summary mode" }
  if (typeof value.active !== "boolean" || typeof value.ended !== "boolean"
      || typeof value.session_id !== "string" || typeof value.started_at !== "string"
      || value.session_id.length > 256 || value.started_at.length > 128)
    return { ok: false, state: "unavailable", message: "Invalid lifecycle fields" }
  if (value.active !== (value.mode === "live_record" && !value.ended))
    return { ok: false, state: "unavailable", message: "Inconsistent lifecycle" }
  if (value.exit_code !== null && !integerInRange(value.exit_code, -2147483648, 2147483647))
    return { ok: false, state: "unavailable", message: "Invalid exit code" }
  var counts = ["events", "client_messages", "server_messages", "invalid_messages", "errors"]
  for (var index = 0; index < counts.length; index++) {
    if (!integerInRange(value[counts[index]], 0, 9007199254740991))
      return { ok: false, state: "unavailable", message: "Invalid event counts" }
  }
  if (typeof value.duration_ms !== "number" || !isFinite(value.duration_ms) || value.duration_ms < 0)
    return { ok: false, state: "unavailable", message: "Invalid duration" }
  if (value.last_method !== null && (typeof value.last_method !== "string" || value.last_method.length > 512))
    return { ok: false, state: "unavailable", message: "Invalid last method" }

  return { ok: true,
    state: value.active ? "recording" : (value.ended ? "completed" : "served"),
    summary: { apiVersion: value.api_version, traceVersion: value.trace_version,
      mode: value.mode, active: value.active, sessionId: value.session_id,
      startedAt: value.started_at, ended: value.ended, exitCode: value.exit_code,
      events: value.events, durationMs: value.duration_ms,
      clientMessages: value.client_messages, serverMessages: value.server_messages,
      invalidMessages: value.invalid_messages, errors: value.errors,
      lastMethod: value.last_method === null ? "" : value.last_method } }
}

function normalizeInspectorUrl(value) {
  var text = String(value === undefined || value === null ? "" : value).trim()
  var match = /^(http):\/\/(127\.0\.0\.1|\[::1\])(?::([0-9]+))?\/?$/i.exec(text)
  if (!match) return ""
  var port = match[3] === undefined ? 80 : Number(match[3])
  if (!integerInRange(port, 1, 65535)) return ""
  return "http://" + match[2].toLowerCase() + (port === 80 ? "" : ":" + String(port))
}

function summaryUrl(base) {
  var normalized = normalizeInspectorUrl(base)
  return normalized === "" ? "" : normalized + "/api/summary"
}

function responseUrlMatches(configuredBase, responseUrl) {
  return summaryUrl(configuredBase) !== "" && String(responseUrl || "") === summaryUrl(configuredBase)
}

function isJsonContentType(value) {
  return /^application\/json(?:\s*;|\s*$)/i.test(String(value || ""))
}

function nextPollDelay(baseMs, failures) {
  var base = integerInRange(baseMs, 250, 60000) ? baseMs : 2000
  var count = integerInRange(failures, 0, 30) ? failures : 0
  return Math.min(MAX_BACKOFF_MS, base * Math.pow(2, count))
}

function durationLabel(milliseconds) {
  if (typeof milliseconds !== "number" || !isFinite(milliseconds) || milliseconds < 0) return "—"
  if (milliseconds < 1000) return Math.round(milliseconds) + " ms"
  if (milliseconds < 60000) return (milliseconds / 1000).toFixed(1) + " s"
  return Math.floor(milliseconds / 60000) + "m " + Math.floor((milliseconds % 60000) / 1000) + "s"
}

function statusLabel(state, summary) {
  if (state === "recording") return "Recording"
  if (state === "served") return "Served trace"
  if (state === "completed") return summary && summary.exitCode !== null ? "Completed · exit " + summary.exitCode : "Completed"
  if (state === "limited") return "Response too large"
  if (state === "incompatible") return "AgentWire update required"
  if (state === "misconfigured") return "Loopback URL required"
  if (state === "offline") return "Inspector offline"
  if (state === "unavailable") return "Trace unavailable"
  return "Connecting"
}
