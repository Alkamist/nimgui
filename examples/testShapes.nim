import pkg/nimengine

func generateCircle(position: Vec2, radius: float, pointCount: int): seq[Vec2] =
  result = newSeq[Vec2](pointCount)
  let spacing = 2 * Pi / pointCount.float
  for i in 0 ..< pointCount:
    let phi = i.float * spacing
    result[i] = vec2(cos(-phi), sin(phi)) * radius + position

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.setBackgroundColor(rgb(32, 32, 32))

let canvas = newCanvas()
let canvasRenderer = newCanvasRenderer()

var position = vec2(0, 0)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)

  let points = generateCircle(position, 200, 32)
  # canvas.addConvexPoly(points, rgb(255, 255, 255), 10.0)
  canvas.addPolyLine(points, rgb(255, 255, 255), 3, 5, true)

  canvas.strokeRect(position.x, position.y, 200, 200, rgb(255, 255, 255), 3.0, 3.0)

  canvasRenderer.render(canvas)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.mouseDown[left]:
    position.x = window.input.mouseX
    position.y = window.input.mouseY

  render()