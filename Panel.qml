import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "io.github.tcballard.agentwire"

  readonly property string configuredUrl: String(setting("inspectorUrl", "http://127.0.0.1:4777"))
  readonly property string inspectorUrl: Model.normalizeInspectorUrl(configuredUrl)
  readonly property int pollIntervalMs: Math.max(250, Math.min(60000, Number(setting("pollIntervalMs", 2000))))
  property string connectionState: "connecting"
  property var summary: Model.emptySummary()
  property int failures: 0
  property int requestSerial: 0
  property var activeRequest: null

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color statusColor: connectionState === "recording" ? "#78dba9"
    : (connectionState === "completed" || connectionState === "served" ? foreground : dim)
  readonly property string barText: connectionState === "recording" || connectionState === "served" || connectionState === "completed"
    ? "AW " + summary.events : "AW"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function schedule() {
    pollTimer.interval = Model.nextPollDelay(root.pollIntervalMs, root.failures)
    pollTimer.restart()
  }

  function fail(state) {
    root.connectionState = state
    root.failures = Math.min(root.failures + 1, 30)
    root.schedule()
  }

  function refresh(force) {
    if (root.inspectorUrl === "") {
      root.connectionState = "misconfigured"
      root.failures = 0
      root.schedule()
      return
    }
    if (root.activeRequest && root.activeRequest.readyState !== XMLHttpRequest.DONE) {
      if (!force) return
      root.requestSerial++
      root.activeRequest.abort()
    }

    var serial = ++root.requestSerial
    var request = new XMLHttpRequest()
    root.activeRequest = request
    root.connectionState = root.summary.events === 0 ? "connecting" : root.connectionState
    request.onreadystatechange = function() {
      if (serial !== root.requestSerial) return
      if ((request.readyState === XMLHttpRequest.HEADERS_RECEIVED || request.readyState === XMLHttpRequest.LOADING)
          && String(request.responseText || "").length > Model.MAX_RESPONSE_CHARS) {
        root.requestSerial++
        request.abort()
        root.activeRequest = null
        requestTimeout.stop()
        root.fail("limited")
        return
      }
      if (request.readyState !== XMLHttpRequest.DONE) return
      root.activeRequest = null
      requestTimeout.stop()

      var body = String(request.responseText || "")
      if (body.length > Model.MAX_RESPONSE_CHARS) { root.fail("limited"); return }
      if (request.status === 0) { root.fail("offline"); return }
      if (!Model.responseUrlMatches(root.inspectorUrl, request.responseURL)
          || !Model.isJsonContentType(request.getResponseHeader("Content-Type"))) {
        root.fail("unavailable")
        return
      }
      if (request.status !== 200) { root.fail("unavailable"); return }
      var parsed
      try { parsed = Model.parseSummary(JSON.parse(body)) }
      catch (error) { root.fail("unavailable"); return }
      if (!parsed.ok) { root.fail(parsed.state); return }
      root.summary = parsed.summary
      root.connectionState = parsed.state
      root.failures = 0
      root.schedule()
    }
    request.open("GET", Model.summaryUrl(root.inspectorUrl))
    request.send()
    requestTimeout.restart()
  }

  function openInspector() {
    if (root.inspectorUrl !== "") Qt.openUrlExternally(root.inspectorUrl)
  }

  onConfiguredUrlChanged: refresh(true)
  onOpenedChanged: if (opened) refresh(true)
  Component.onCompleted: refresh(false)

  Timer {
    id: pollTimer
    interval: root.pollIntervalMs
    repeat: false
    onTriggered: root.refresh(false)
  }

  Timer {
    id: requestTimeout
    interval: 5000
    repeat: false
    onTriggered: {
      if (!root.activeRequest) return
      root.requestSerial++
      root.activeRequest.abort()
      root.activeRequest = null
      root.fail("offline")
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.barText
    foreground: root.statusColor
    tooltipText: Model.statusLabel(root.connectionState, root.summary)
    onPressed: function(code) {
      if (code === Qt.RightButton) root.openInspector()
      else if (code === Qt.MiddleButton) root.refresh(true)
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.openInspector()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === "r" || text === "R") root.refresh(true)
        else if (text === "o" || text === "O") root.openInspector()
      }

      ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(8)

        Text {
          textFormat: Text.PlainText
          text: "AgentWire"
          color: root.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.title
          font.bold: true
        }
        Text {
          textFormat: Text.PlainText
          text: Model.statusLabel(root.connectionState, root.summary)
          color: root.statusColor
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }
        Text {
          textFormat: Text.PlainText
          text: "Events  " + root.summary.events + "   Client →  " + root.summary.clientMessages + "   Server →  " + root.summary.serverMessages
          color: root.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }
        Text {
          textFormat: Text.PlainText
          text: "Duration  " + Model.durationLabel(root.summary.durationMs) + (root.summary.errors > 0 ? "   Errors  " + root.summary.errors : "")
          color: root.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }
        Text {
          textFormat: Text.PlainText
          visible: root.summary.lastMethod !== ""
          text: "Last  " + root.summary.lastMethod
          color: root.dim
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
          Layout.fillWidth: true
        }
        Text {
          textFormat: Text.PlainText
          text: "Enter/O: inspector   R: refresh   Esc: close"
          color: root.dim
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
