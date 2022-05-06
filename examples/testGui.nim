import pkg/nimengine

let window = newWindow()

let openGlContext = gfx.newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.setBackgroundColor(rgb(32, 32, 32))

let canvas = gfx.newCanvas()
let canvasRenderer = gfx.newCanvasRenderer()

let gui = newWidget(canvas, window.input)

let width = window.width / 5.0
let height = window.height / 5.0

for i in 0 ..< 5:
  for j in 0 ..< 5:
    let b = newButtonWidget()
    b.x = 20
    b.y = 40
    b.width = 100
    b.height = 80
    b.onClicked = proc() = echo "Clicked"

    let w = newWindowWidget()
    w.x = i.float * width
    w.y = j.float * height
    w.width = 300
    w.height = 200
    w.children.add(b)

    gui.children.add(w)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)
  gui.draw()
  canvasRenderer.render(canvas)

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()
  gui.update()
  render()