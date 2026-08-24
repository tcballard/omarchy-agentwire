import QtQuick
import QtQuick.Layouts

// Details panel for the AgentWire bar widget. Receives the latest inspector
// summary from BarWidget.qml and links out to the full browser inspector.
Panel {
    id: panel
    moduleName: "io.github.tcballard.agentwire"

    property string inspectorUrl: "http://127.0.0.1:4777"
    property var summary: ({
        protocolCount: 0,
        clientCount: 0,
        serverCount: 0,
        errorCount: 0,
        lastMethod: "",
        ended: false
    })

    implicitWidth: 280
    implicitHeight: column.implicitHeight + 24

    PanelKeyCatcher {
        anchors.fill: parent
        onEscapePressed: panel.close()

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Text {
                text: "AgentWire"
                font.bold: true
            }

            Text {
                text: panel.summary.ended
                    ? "session finished"
                    : (panel.summary.protocolCount > 0 ? "recording" : "waiting for events")
                opacity: 0.7
            }

            Text { text: "events   " + panel.summary.protocolCount }
            Text { text: "client → " + panel.summary.clientCount }
            Text { text: "server → " + panel.summary.serverCount }
            Text {
                text: "errors   " + panel.summary.errorCount
                visible: panel.summary.errorCount > 0
            }
            Text {
                text: "last     " + panel.summary.lastMethod
                visible: panel.summary.lastMethod !== ""
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: "Open inspector ↗"
                opacity: hoverArea.containsMouse ? 1.0 : 0.8

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Qt.openUrlExternally(panel.inspectorUrl)
                        panel.close()
                    }
                }
            }
        }
    }
}
