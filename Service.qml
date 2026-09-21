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

  property var metrics: ({
    cpu: { usage: 0, temp: 0, text: "0%", tempText: "0°C" },
    gpu: { usage: 0, temp: 0, text: "0%", tempText: "0°C" },
    ram: { usedBytes: 0, totalBytes: 0, percent: 0, text: "0%", detail: "0 GB" },
    vram: { usedBytes: 0, totalBytes: 0, percent: 0, text: "0%", detail: "0 GB" },
    net: { rxRate: 0, txRate: 0, downText: "↓ 0 B/s", upText: "↑ 0 B/s", totalKb: 0 },
    history: { cpu: [], gpu: [], net: [] }
  })
  property bool hudVisible: true

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
  }
}
