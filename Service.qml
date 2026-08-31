import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  visible: false

  property var manifest: null
  property bool hubWanted: false
  property string lastError: ""

  readonly property string sourceDir: manifest && manifest.__sourceDir
    ? String(manifest.__sourceDir) : ""
  readonly property string runtimeDir: String(Quickshell.env("XDG_RUNTIME_DIR") || "")
  readonly property string launcherPath: sourceDir === "" ? "" : sourceDir + "/bin/agentwire"
  readonly property string snapshotPath: runtimeDir === "" ? "" : runtimeDir + "/agentwire/inspector.json"
  readonly property bool ready: launcherPath !== "" && snapshotPath !== ""

  function startHub() {
    if (!ready || hubProcess.running) return
    lastError = ""
    hubProcess.command = [launcherPath, "hub", "--listen", "127.0.0.1:4777"]
    hubWanted = true
  }

  onReadyChanged: {
    if (ready) startHub()
    else hubWanted = false
  }
  Component.onCompleted: startHub()

  Timer {
    id: restartTimer
    interval: 2000
    repeat: false
    onTriggered: root.startHub()
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
      if (root.ready) {
        if (exitCode !== 0 && root.lastError === "") root.lastError = "AgentWire hub stopped"
        restartTimer.restart()
      }
    }
  }
}
