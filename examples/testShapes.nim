import pkg/nimengine

let window = newWindow()

let openGlContext = newOpenGlContext(cast[pointer](window.platform.handle))
openGlContext.select()

let canvas = newCanvas()
let canvasRenderer = newCanvasRenderer()

func generateCircle(position: Vec2, radius: float, pointCount: int): seq[Vec2] =
  result = newSeq[Vec2](pointCount)
  let spacing = 2 * Pi / pointCount.float
  for i in 0 ..< pointCount:
    let phi = i.float * spacing
    result[i] = vec2(cos(-phi), sin(phi)) * radius + position

var position = vec2(0, 0)

proc render() =
  glViewport(0.GLsizei, 0.GLsizei, window.width.GLsizei, window.height.GLsizei)
  glScissor(0.GLint, 0.GLint, window.width.GLsizei, window.height.GLsizei)
  glClearColor(0.1, 0.1, 0.1, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  canvas.beginFrame(window.width, window.height)

  let points = generateCircle(position, 200, 16)
  canvas.addConvexPoly(points, rgbaU(255, 0, 0, 255))
  # canvas.addPolyLine(points, rgbaU(255, 255, 255, 255), 1.0, 0, true)

  canvasRenderer.render(canvas)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.isPressed(MouseButton.Left):
    position.x = window.input.mouseX
    position.y = window.input.mouseY

  render()