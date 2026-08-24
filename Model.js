.pragma library

// Summarize the event list served by the AgentWire inspector at
// /api/events. Events with direction "meta" bracket the session; everything
// else is a protocol message with direction, kind, method, and payload.
function summarize(events) {
    const summary = {
        protocolCount: 0,
        clientCount: 0,
        serverCount: 0,
        errorCount: 0,
        lastMethod: "",
        ended: false
    }
    for (let index = 0; index < events.length; index++) {
        const event = events[index]
        if (event.direction === "meta") {
            if (event.kind === "session_end") summary.ended = true
            continue
        }
        if (event.direction === "client_to_server") {
            summary.clientCount++
        } else if (event.direction === "server_to_client") {
            summary.serverCount++
        } else {
            continue
        }
        summary.protocolCount++
        if (event.payload && event.payload.error !== undefined) summary.errorCount++
        summary.lastMethod = event.method || event.kind || ""
    }
    return summary
}
