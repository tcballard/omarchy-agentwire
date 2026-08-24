import QtQuick
import "Model.js" as Model

// Bar entry point for the AgentWire plugin. Polls the local AgentWire
// inspector (agentwire record --ui / agentwire serve) and shows whether a
// recording session is live. The details panel is loaded internally per the
// Omarchy plugin conventions; opened, open(), and close() are forwarded to
// it.
BarWidget {
    id: root
    moduleName: "io.github.tcballard.agentwire"

    // The inspector binds to loopback; change this if you pass a different
    // --ui HOST:PORT to agentwire.
    property string inspectorUrl: "http://127.0.0.1:4777"
    property int pollIntervalMs: 2000

    property bool reachable: false
    property bool ended: false
    property int protocolCount: 0
    property string lastMethod: ""
    readonly property bool recording: reachable && !ended

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    function refresh() {
        const request = new XMLHttpRequest()
        request.onreadystatechange = function () {
            if (request.readyState !== XMLHttpRequest.DONE) return
            if (request.status === 200) {
                try {
                    const summary = Model.summarize(JSON.parse(request.responseText))
                    root.reachable = true
                    root.ended = summary.ended
                    root.protocolCount = summary.protocolCount
                    root.lastMethod = summary.lastMethod
                    if (panelLoader.item) panelLoader.item.summary = summary
                    return
                } catch (error) {
                    // Fall through to the unreachable state.
                }
            }
            root.reachable = false
            root.ended = false
            root.protocolCount = 0
            root.lastMethod = ""
        }
        request.open("GET", inspectorUrl + "/api/events")
        request.send()
    }

    Timer {
        interval: root.pollIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Row {
        id: row
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: 8
            height: 8
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            color: root.recording ? "#a7f3d0" : "#8793a1"
            opacity: root.reachable ? 1.0 : 0.35
        }

        Text {
            text: root.reachable ? "AW " + root.protocolCount : "AW"
            opacity: root.reachable ? 1.0 : 0.5
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // The panel is loaded from the bar entry point; do not add a separate
    // manifest kind for it.
    Loader {
        id: panelLoader
        active: root.opened
        source: "Panel.qml"
        onLoaded: {
            item.inspectorUrl = root.inspectorUrl
            item.summary = Model.summarize([])
            root.refresh()
        }
    }

    onOpenedChanged: {
        if (!panelLoader.item) return
        if (root.opened) panelLoader.item.open()
        else panelLoader.item.close()
    }
}
