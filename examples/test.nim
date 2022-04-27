import pkg/nimengine

let window = newWindow()
window.enableRenderer()
window.renderer.setBackgroundColor(0.1, 0.1, 0.1, 1.0)

let list = newDrawList()

func generateCircle(position: Vec2, radius: float, pointCount: int): seq[Vec2] =
  result = newSeq[Vec2](pointCount)
  let spacing = 2 * Pi / pointCount.float
  for i in 0 ..< pointCount:
    let phi = i.float * spacing
    result[i] = vec2(cos(-phi), sin(-phi)) * radius + position

window.renderer.onRender2d = proc() =
  list.reset()

  # let points = [
  #   vec2(50, 50),
  #   vec2(150, 400),
  #   vec2(250, 50),
  #   vec2(350, 500),
  # ]
  # list.addPolyLine(points, rgba(0, 1, 0, 1), 5)

  let w = window.width / 4.0
  let h = window.height / 4.0

  for i in 0 ..< 4:
    for j in 0 ..< 4:
      let position = vec2(i.float * w + 0.5 * w, j.float * h + 0.5 * h)
      let diameter = min(w * 0.9, h * 0.9)
      let points = generateCircle(position, 0.5 * diameter, 8)
      list.addConvexPolyFilledAntiAlias(points, rgba(0, 1, 0, 1))

  window.renderer.drawDrawList(list)

while not window.isClosed:
  window.update()