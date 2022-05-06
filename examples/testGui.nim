import pkg/nimengine

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.setBackgroundColor(rgb(32, 32, 32))

let canvas = newCanvas()
let canvasRenderer = newCanvasRenderer()

let gui = newWidget(canvas, window.input)

for i in 0 ..< 10:
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
  w.x = i.float * 30.0
  w.y = i.float * 30.0
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