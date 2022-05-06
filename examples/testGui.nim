import pkg/nimengine

let window = newWindow()

let openGlContext = newOpenGlContext(cast[pointer](window.platform.handle))
openGlContext.select()

let canvas = newCanvas()
let canvasRenderer = newCanvasRenderer()

let gui = newWidget()

for i in 0 ..< 2:
  let b = newButtonWidget()
  b.x = 20
  b.y = 40
  b.width = 50
  b.height = 50
  closureScope:
    let windowNumber = i + 1
    b.onClicked = proc() =
      echo "Clicked " & $windowNumber

  let w = newWindowWidget()
  w.x = i.float * 10.0
  w.y = i.float * 10.0
  w.width = 300
  w.height = 200
  w.addChild(b)

  gui.addChild(w)

proc render() =
  glViewport(0.GLsizei, 0.GLsizei, window.width.GLsizei, window.height.GLsizei)
  glScissor(0.GLint, 0.GLint, window.width.GLsizei, window.height.GLsizei)
  glClearColor(0.1, 0.1, 0.1, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  canvas.beginFrame(window.width, window.height)
  gui.draw(canvas)
  canvasRenderer.render(canvas)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()
  gui.width = window.width
  gui.height = window.height
  gui.update(window.input)
  render()