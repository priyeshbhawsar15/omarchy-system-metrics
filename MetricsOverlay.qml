import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons as Commons

PanelWindow {
  id: metricsWindow

  property var pluginService: null
  property string targetScreenName: "DP-4"

  readonly property color themeAccent: (Commons.Color.bar && Commons.Color.bar.active)
    ? Commons.Color.bar.active : Commons.Color.accent

  readonly property bool isPinned: pluginService ? pluginService.isPinned : false
  readonly property bool autohideEnabled: pluginService ? pluginService.autohideEnabled : false
  property bool isHovered: false
  readonly property bool isRevealed: !autohideEnabled || isHovered

  screen: {
    const list = Quickshell.screens || []
    for (let i = 0; i < list.length; i++) {
      if (list[i] && list[i].name === targetScreenName) return list[i]
    }
    return list.length > 1 ? list[1] : (list.length > 0 ? list[0] : null)
  }

  anchors {
    top: true
    right: true
  }

  margins {
    top: Commons.Style.space(455)
    right: Commons.Style.space(16)
  }

  implicitWidth: 390
  implicitHeight: hudFrame.implicitHeight
  color: "transparent"

  WlrLayershell.namespace: "omarchy-system-metrics-hud"
  WlrLayershell.layer: isPinned ? WlrLayer.Overlay : WlrLayer.Bottom
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore

  mask: Region {
    x: metricsWindow.isRevealed ? 0 : Math.max(0, metricsWindow.width - 14)
    y: 0
    width: metricsWindow.isRevealed ? metricsWindow.width : 14
    height: metricsWindow.height
  }

  Timer {
    id: autoHideTimer
    interval: 700
    onTriggered: {
      if (metricsWindow.autohideEnabled && !cardHoverArea.containsMouse && !edgeHoverArea.containsMouse) {
        metricsWindow.isHovered = false
      }
    }
  }

  function requestShow() {
    autoHideTimer.stop()
    metricsWindow.isHovered = true
  }

  function requestHide() {
    if (metricsWindow.autohideEnabled) {
      autoHideTimer.restart()
    }
  }

  // Edge Trigger Sensor
  MouseArea {
    id: edgeHoverArea
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 14
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    z: 100
    onEntered: metricsWindow.requestShow()
    onExited: metricsWindow.requestHide()
  }

  Rectangle {
    id: hudFrame
    width: metricsWindow.implicitWidth
    implicitHeight: mainCol.implicitHeight + Commons.Style.space(28)
    anchors.top: parent.top
    x: metricsWindow.isRevealed ? 0 : (parent.width + 20)
    radius: Commons.Style.space(12)
    color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.85)
    border.width: 1
    border.color: Qt.rgba(metricsWindow.themeAccent.r, metricsWindow.themeAccent.g, metricsWindow.themeAccent.b, 0.25)
    clip: true

    Behavior on x {
      NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
    }

    MouseArea {
      id: cardHoverArea
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      onEntered: metricsWindow.requestShow()
      onExited: metricsWindow.requestHide()
    }

    ColumnLayout {
      id: mainCol
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: Commons.Style.space(14)
      spacing: Commons.Style.space(12)

      // Header
      RowLayout {
        Layout.fillWidth: true
        spacing: Commons.Style.space(8)

        Text {
          text: "󰍛"
          color: metricsWindow.themeAccent
          font.family: Commons.Style.font.family
          font.pixelSize: Commons.Style.font.title
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 1

          Text {
            text: "System Telemetry"
            color: Commons.Color.foreground
            font.family: Commons.Style.font.family
            font.pixelSize: Commons.Style.font.body
            font.weight: Font.Bold
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          Text {
            text: "Real-time hardware metrics"
            color: Commons.Color.muted
            font.family: Commons.Style.font.family
            font.pixelSize: Commons.Style.font.caption
            elide: Text.ElideRight
            Layout.fillWidth: true
          }
        }

        // AUTO-HIDE TOGGLE BUTTON
        Rectangle {
          width: 28
          height: 28
          radius: 6
          color: metricsWindow.autohideEnabled
            ? Qt.rgba(metricsWindow.themeAccent.r, metricsWindow.themeAccent.g, metricsWindow.themeAccent.b, 0.25)
            : (autohideHover.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12) : "transparent")
          border.width: 1
          border.color: metricsWindow.autohideEnabled
            ? metricsWindow.themeAccent : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.18)

          Text {
            anchors.centerIn: parent
            text: metricsWindow.autohideEnabled ? "󰘖" : "󱊒"
            color: metricsWindow.autohideEnabled ? metricsWindow.themeAccent : Commons.Color.foreground
            font.family: Commons.Style.font.family
            font.pixelSize: 14
          }

          MouseArea {
            id: autohideHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (metricsWindow.pluginService) metricsWindow.pluginService.toggleAutohide()
            }
          }
        }

        // PIN TOGGLE BUTTON
        Rectangle {
          width: 28
          height: 28
          radius: 6
          color: metricsWindow.isPinned
            ? Qt.rgba(metricsWindow.themeAccent.r, metricsWindow.themeAccent.g, metricsWindow.themeAccent.b, 0.25)
            : (pinHover.containsMouse ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12) : "transparent")
          border.width: 1
          border.color: metricsWindow.isPinned
            ? metricsWindow.themeAccent : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.18)

          Text {
            anchors.centerIn: parent
            text: metricsWindow.isPinned ? "󰐃" : "󰤱"
            color: metricsWindow.isPinned ? metricsWindow.themeAccent : Commons.Color.foreground
            font.family: Commons.Style.font.family
            font.pixelSize: 14
          }

          MouseArea {
            id: pinHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (metricsWindow.pluginService) metricsWindow.pluginService.togglePin()
            }
          }
        }
      }

      // SECTION 1: CIRCULAR PROGRESS RINGS (RAM & VRAM)
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 154
        radius: Commons.Style.space(8)
        color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.70)
        border.width: 1
        border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)

        RowLayout {
          anchors.fill: parent
          anchors.margins: Commons.Style.space(10)
          spacing: Commons.Style.space(8)

          ProgressRing {
            Layout.fillWidth: true
            title: "System RAM"
            icon: "󰘚"
            ringColor: metricsWindow.themeAccent
            percent: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? Number(metricsWindow.pluginService.metrics.ram.percent || 0) : 0
            detail: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? String(metricsWindow.pluginService.metrics.ram.detail || "0 GB") : "0 GB"
          }

          Rectangle {
            width: 1
            height: 100
            color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.10)
          }

          ProgressRing {
            Layout.fillWidth: true
            title: "GPU VRAM"
            icon: "󰢮"
            ringColor: metricsWindow.themeAccent
            percent: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? Number(metricsWindow.pluginService.metrics.vram.percent || 0) : 0
            detail: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? String(metricsWindow.pluginService.metrics.vram.detail || "0 GB") : "0 GB"
          }
        }
      }

      // SECTION 2: CPU METRICS & GRAPH
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: cpuCol.implicitHeight + Commons.Style.space(16)
        radius: Commons.Style.space(8)
        color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.70)
        border.width: 1
        border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)

        ColumnLayout {
          id: cpuCol
          anchors.fill: parent
          anchors.margins: Commons.Style.space(10)
          spacing: Commons.Style.space(6)

          RowLayout {
            Layout.fillWidth: true
            spacing: Commons.Style.space(6)

            Text {
              text: "󰻠"
              color: metricsWindow.themeAccent
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.body
            }

            Text {
              text: "CPU"
              color: Commons.Color.foreground
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.bodySmall
              font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Text {
              text: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? (metricsWindow.pluginService.metrics.cpu.text + "  ·  " + metricsWindow.pluginService.metrics.cpu.tempText) : "0% · 0°C"
              color: metricsWindow.themeAccent
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.caption
              font.weight: Font.Bold
            }
          }

          SparklineGraph {
            Layout.fillWidth: true
            implicitHeight: 34
            lineColor: metricsWindow.themeAccent
            maxVal: 100
            points: metricsWindow.pluginService && metricsWindow.pluginService.metrics && metricsWindow.pluginService.metrics.history ? metricsWindow.pluginService.metrics.history.cpu : []
          }
        }
      }

      // SECTION 3: GPU METRICS & GRAPH
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: gpuCol.implicitHeight + Commons.Style.space(16)
        radius: Commons.Style.space(8)
        color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.70)
        border.width: 1
        border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)

        ColumnLayout {
          id: gpuCol
          anchors.fill: parent
          anchors.margins: Commons.Style.space(10)
          spacing: Commons.Style.space(6)

          RowLayout {
            Layout.fillWidth: true
            spacing: Commons.Style.space(6)

            Text {
              text: "󰢮"
              color: metricsWindow.themeAccent
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.body
            }

            Text {
              text: "GPU (AMD)"
              color: Commons.Color.foreground
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.bodySmall
              font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Text {
              text: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? (metricsWindow.pluginService.metrics.gpu.text + "  ·  " + metricsWindow.pluginService.metrics.gpu.tempText) : "0% · 0°C"
              color: metricsWindow.themeAccent
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.caption
              font.weight: Font.Bold
            }
          }

          SparklineGraph {
            Layout.fillWidth: true
            implicitHeight: 34
            lineColor: metricsWindow.themeAccent
            maxVal: 100
            points: metricsWindow.pluginService && metricsWindow.pluginService.metrics && metricsWindow.pluginService.metrics.history ? metricsWindow.pluginService.metrics.history.gpu : []
          }
        }
      }

      // SECTION 4: NETWORK METRICS & GRAPH
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: netCol.implicitHeight + Commons.Style.space(16)
        radius: Commons.Style.space(8)
        color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.70)
        border.width: 1
        border.color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.12)

        ColumnLayout {
          id: netCol
          anchors.fill: parent
          anchors.margins: Commons.Style.space(10)
          spacing: Commons.Style.space(6)

          RowLayout {
            Layout.fillWidth: true
            spacing: Commons.Style.space(6)

            Text {
              text: "󰖩"
              color: metricsWindow.themeAccent
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.body
            }

            Text {
              text: "Network"
              color: Commons.Color.foreground
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.bodySmall
              font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Text {
              text: metricsWindow.pluginService && metricsWindow.pluginService.metrics ? (metricsWindow.pluginService.metrics.net.downText + "  " + metricsWindow.pluginService.metrics.net.upText) : "↓ 0 B/s  ↑ 0 B/s"
              color: metricsWindow.themeAccent
              font.family: Commons.Style.font.family
              font.pixelSize: Commons.Style.font.caption
              font.weight: Font.Bold
            }
          }

          SparklineGraph {
            Layout.fillWidth: true
            implicitHeight: 34
            lineColor: metricsWindow.themeAccent
            maxVal: 500
            points: metricsWindow.pluginService && metricsWindow.pluginService.metrics && metricsWindow.pluginService.metrics.history ? metricsWindow.pluginService.metrics.history.net : []
          }
        }
      }
    }
  }

  // Edge Grab Handle Pill (when collapsed in auto-hide mode)
  Rectangle {
    anchors.right: parent.right
    anchors.verticalCenter: hudFrame.verticalCenter
    width: 6
    height: 80
    radius: 3
    color: metricsWindow.themeAccent
    opacity: metricsWindow.isRevealed ? 0 : 0.85
    z: 90

    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
  }
}
