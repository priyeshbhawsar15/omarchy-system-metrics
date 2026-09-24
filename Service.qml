pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: root

  property var manifest: null
  property var shell: null

  readonly property string homeDir: Quickshell.env("HOME") || ""
  readonly property string collectorBin: (manifest && manifest.__sourceDir)
    ? (manifest.__sourceDir + "/bin/system-metrics-collector")
    : (homeDir + "/.config/omarchy/plugins/priyesh.system-metrics/bin/system-metrics-collector")
  readonly property string stateFilePath: homeDir + "/.local/state/omarchy/system-metrics/state.json"
  readonly property string settingsFilePath: homeDir + "/.local/state/omarchy/system-metrics/settings.json"

  property var metrics: ({
    cpu: { usage: 0, temp: 0, text: "0%", tempText: "0°C" },
    gpu: { usage: 0, temp: 0, text: "0%", tempText: "0°C" },
    ram: { usedBytes: 0, totalBytes: 0, percent: 0, text: "0%", detail: "0 GB" },
    vram: { usedBytes: 0, totalBytes: 0, percent: 0, text: "0%", detail: "0 GB" },
    net: { rxRate: 0, txRate: 0, downText: "↓ 0 B/s", upText: "↑ 0 B/s", totalKb: 0 },
    history: { cpu: [], gpu: [], net: [] }
  })
  property bool hudVisible: true
  property bool isPinned: false
  property bool autohideEnabled: false

  function loadSettings(jsonText) {
    if (!jsonText || jsonText.length === 0) return
    try {
      var s = JSON.parse(jsonText)
      if (s.isPinned !== undefined) root.isPinned = (s.isPinned === true)
      if (s.autohideEnabled !== undefined) root.autohideEnabled = (s.autohideEnabled === true)
    } catch (e) {}
  }

  function saveSettings() {
    saveSettingsProc.command = [
      "python3", "-c",
      "import json, os, sys; p = sys.argv[1]; os.makedirs(os.path.dirname(p), exist_ok=True); open(p, 'w').write(json.dumps({'isPinned': sys.argv[2] == '1', 'autohideEnabled': sys.argv[3] == '1'}))",
      root.settingsFilePath, root.isPinned ? "1" : "0", root.autohideEnabled ? "1" : "0"
    ]
    saveSettingsProc.running = true
  }

  function togglePin() {
    root.isPinned = !root.isPinned
    root.saveSettings()
  }

  function toggleAutohide() {
    root.autohideEnabled = !root.autohideEnabled
    root.saveSettings()
  }

  function handleState(jsonText) {
    if (!jsonText || jsonText.length === 0) return
    try {
      var data = JSON.parse(jsonText)
      if (data.cpu && data.gpu && data.ram) {
        root.metrics = data
      }
    } catch (e) {
      console.warn("system-metrics: parse error", e)
    }
  }

  function sample() {
    sampleProc.running = true
  }

  function toggle() {
    root.hudVisible = !root.hudVisible
  }

  FileView {
    id: stateWatcher
    path: root.stateFilePath
    printErrors: false
    watchChanges: true
    onLoaded: {
      root.handleState(stateWatcher.text())
    }
  }

  FileView {
    id: settingsWatcher
    path: root.settingsFilePath
    printErrors: false
    watchChanges: true
    onLoaded: root.loadSettings(settingsWatcher.text())
    onTextChanged: root.loadSettings(settingsWatcher.text())
  }

  Process {
    id: saveSettingsProc
  }

  Process {
    id: sampleProc
    command: ["python3", root.collectorBin, "once"]
    stdout: StdioCollector {
      id: sampleOut
      waitForEnd: true
      onStreamFinished: {
        root.handleState(sampleOut.text)
      }
    }
  }

  Timer {
    id: pollTimer
    interval: 1500
    running: true
    repeat: true
    onTriggered: root.sample()
  }

  Component.onCompleted: {
    if (settingsWatcher.loaded) {
      root.loadSettings(settingsWatcher.text())
    }
    if (stateWatcher.loaded) {
      root.handleState(stateWatcher.text())
    }
    root.sample()
  }

  MetricsOverlay {
    id: metricsWindow
    pluginService: root
    visible: root.hudVisible
  }

  IpcHandler {
    target: "priyesh.system-metrics"

    function sample(): void { root.sample() }
    function toggle(): void { root.toggle() }
    function show(): void { root.hudVisible = true }
    function hide(): void { root.hudVisible = false }
    function togglePin(): void { root.togglePin() }
    function toggleAutohide(): void { root.toggleAutohide() }
  }
}
