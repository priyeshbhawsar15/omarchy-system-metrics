import QtQuick
import qs.Commons as Commons

Item {
  id: ring

  property real percent: 0
  property string title: "Memory"
  property string detail: "0 GB / 0 GB"
  property color ringColor: Commons.Color.accent
  property color trackColor: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.10)
  property string icon: "󰍛"

  implicitWidth: 165
  implicitHeight: 140

  Canvas {
    id: canvas
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    width: 96
    height: 96
    antialiasing: true

    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      
      var centerX = width / 2
      var centerY = height / 2
      var radius = (width - 12) / 2
      
      // Track
      ctx.beginPath()
      ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
      ctx.lineWidth = 6
      ctx.strokeStyle = ring.trackColor
      ctx.stroke()
      
      // Active Arc
      var startAngle = -Math.PI / 2
      var endAngle = startAngle + (Math.max(0, Math.min(100, ring.percent)) / 100) * 2 * Math.PI
      
      ctx.beginPath()
      ctx.arc(centerX, centerY, radius, startAngle, endAngle)
      ctx.lineWidth = 6
      ctx.lineCap = "round"
      ctx.strokeStyle = ring.ringColor
      ctx.stroke()
    }
  }

  onPercentChanged: canvas.requestPaint()
  Component.onCompleted: canvas.requestPaint()

  // Center text inside the ring
  Column {
    anchors.centerIn: canvas
    spacing: 0

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Math.round(ring.percent) + "%"
      color: Commons.Color.foreground
      font.family: Commons.Style.font.family
      font.pixelSize: Commons.Style.font.bodySmall
      font.weight: Font.Bold
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: ring.icon
      color: ring.ringColor
      font.family: Commons.Style.font.family
      font.pixelSize: Commons.Style.font.caption
    }
  }

  // Label & Detail below the ring
  Column {
    anchors.top: canvas.bottom
    anchors.topMargin: Commons.Style.space(4)
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 1

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: ring.title
      color: Commons.Color.foreground
      font.family: Commons.Style.font.family
      font.pixelSize: Commons.Style.font.caption
      font.weight: Font.DemiBold
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: ring.detail
      color: Commons.Color.muted
      font.family: Commons.Style.font.family
      font.pixelSize: Commons.Style.font.caption - 1
    }
  }
}
