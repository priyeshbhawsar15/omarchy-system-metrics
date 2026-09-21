import QtQuick

Canvas {
  id: graph

  property var points: []
  property color lineColor: "#10b981"
  property real maxVal: 100

  implicitWidth: 160
  implicitHeight: 36
  antialiasing: true

  onPointsChanged: requestPaint()
  Component.onCompleted: requestPaint()

  onPaint: {
    var ctx = getContext("2d")
    ctx.clearRect(0, 0, width, height)
    
    if (!points || points.length < 2) return
    
    var len = points.length
    var step = width / (len - 1)
    var m = maxVal > 0 ? maxVal : 100
    
    // Auto-adjust scale if any point exceeds maxVal
    for (var i = 0; i < len; i++) {
      if (points[i] > m) m = points[i]
    }
    
    // Draw Filled Area
    ctx.beginPath()
    ctx.moveTo(0, height)
    for (var i = 0; i < len; i++) {
      var val = Math.max(0, Math.min(m, points[i]))
      var x = i * step
      var y = height - (val / m) * (height - 4) - 2
      ctx.lineTo(x, y)
    }
    ctx.lineTo(width, height)
    ctx.closePath()
    
    var grad = ctx.createLinearGradient(0, 0, 0, height)
    grad.addColorStop(0, Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.35))
    grad.addColorStop(1, Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.02))
    ctx.fillStyle = grad
    ctx.fill()
    
    // Draw Top Stroke
    ctx.beginPath()
    for (var i = 0; i < len; i++) {
      var val = Math.max(0, Math.min(m, points[i]))
      var x = i * step
      var y = height - (val / m) * (height - 4) - 2
      if (i === 0) ctx.moveTo(x, y)
      else ctx.lineTo(x, y)
    }
    ctx.lineWidth = 2
    ctx.strokeStyle = lineColor
    ctx.stroke()
  }
}
