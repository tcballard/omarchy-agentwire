import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  visible: false

  property var manifest: null
  property bool hubWanted: false
  property bool destroying: false
  property int restartCount: 0
  property string lastError: ""
  readonly property int maxRestarts: 5

  readonly property string sourceDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir) : ""
  readonly property string runtimeDir: String(Quickshell.env("XDG_RUNTIME_DIR") || "")
  readonly property string launcherPath: sourceDir === "" ? "" : sourceDir + "/bin/agentwire"
  readonly property string snapshotPath: runtimeDir === "" ? "" : runtimeDir + "/agentwire/inspector.json"
  readonly property bool ready: launcherPath !== "" && snapshotPath !== ""

  function startHub() {
    if (!ready || destroying || hubProcess.running || restartCount >= maxRestarts) return
    lastError = ""
    hubProcess.command = [launcherPath, "hub", "--listen", "127.0.0.1:4777"]
    hubWanted = true
  }

  onReadyChanged: {
    if (ready) startHub()
    else {
      restartTimer.stop()
      stabilityTimer.stop()
      hubWanted = false
      restartCount = 0
    }
  }
  Component.onCompleted: startHub()
  Component.onDestruction: {
    destroying = true
    restartTimer.stop()
    stabilityTimer.stop()
    hubWanted = false
    hubProcess.running = false
  }

  Timer {
    id: restartTimer
    interval: 1000
    repeat: false
    onTriggered: root.startHub()
  }

  Timer {
    id: stabilityTimer
    interval: 60000
    repeat: false
    onTriggered: root.restartCount = 0
  }

  Process {
    id: hubProcess
    running: root.hubWanted
    command: []
    stdout: SplitParser { onRead: function(data) {} }
    stderr: SplitParser {
      onRead: function(data) {
        var line = String(data || "").replace(/\s+/g, " ").trim()
        if (line !== "" && line.indexOf("AgentWire hub:") !== 0)
          root.lastError = line.substring(0, 160)
      }
    }
    onExited: function(exitCode) {
      root.hubWanted = false
      stabilityTimer.stop()
      if (root.ready && !root.destroying && root.restartCount < root.maxRestarts) {
        if (exitCode !== 0 && root.lastError === "") root.lastError = "AgentWire hub stopped"
        root.restartCount++
        restartTimer.interval = Math.min(30000, 1000 * Math.pow(2, root.restartCount - 1))
        restartTimer.restart()
      } else if (root.ready && !root.destroying) {
        root.lastError = "AgentWire hub restart limit reached"
      }
    }
    onRunningChanged: {
      if (running) stabilityTimer.restart()
      else stabilityTimer.stop()
    }
  }
}
