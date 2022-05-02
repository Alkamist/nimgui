import pkg/nimengine

let window = newWindow()
window.enableRenderer()
window.renderer.setBackgroundColor(0.01, 0.01, 0.01, 1.0)

let canvas = newCanvas()

func generateCircle(position: Vec2, radius: float, pointCount: int): seq[Vec2] =
  result = newSeq[Vec2](pointCount)
  let spacing = 2 * Pi / pointCount.float
  for i in 0 ..< pointCount:
    let phi = i.float * spacing
    result[i] = vec2(cos(-phi), sin(-phi)) * radius + position

window.renderer.onRender2d = proc() =
  canvas.reset()

  let w = window.width / 2.0
  let h = window.height / 2.0

  for i in 0 ..< 2:
    for j in 0 ..< 2:
      let position = vec2(i.float * w, j.float * h)
      let left = (position.x + w * 0.05).round
      let right = (position.x + w * 0.95).round
      let bottom = (position.y + h * 0.05).round
      let top = (position.y + h * 0.95).round
      let points = [
        vec2(left, bottom),
        vec2(left, top),
        vec2(right, top),
        vec2(right, bottom),
      ]
      let color = rgba(0.3, 0.3, 0.3, 1)
      canvas.addConvexPoly(points, color)
      canvas.addPolyLine(points, color.lightened(0.5), 1.0, 0.5, true)

  for i in 0 ..< 2:
    for j in 0 ..< 2:
      let position = vec2(i.float * w + 0.5 * w, j.float * h + 0.5 * h)
      let diameter = min(w * 0.6, h * 0.6)
      let points = generateCircle(position, diameter * 0.5, 3)
      let color = rgba(0.2, 0.3, 0.5, 1)
      canvas.addConvexPoly(points, color)
      canvas.addPolyLine(points, color.lightened(0.5), 1.0, 0.5, true)

  window.renderer.draw(canvas)

while not window.isClosed:
  window.update()