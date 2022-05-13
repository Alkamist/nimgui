import pkg/nimengine

let window = newWindow()

let openGlContext = gfx.newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.setBackgroundColor(0.1, 0.1, 0.1, 1.0)

let canvas = gfx.newCanvas()
canvas.loadFont("examples/consola.ttf", 13)
# canvas.loadFont("examples/Roboto-Regular_1.ttf", 13)

let gui = newWidget(canvas, window.input)

let width = window.width / 5.0
let height = window.height / 5.0

for i in 0 ..< 5:
  for j in 0 ..< 5:
    let button = newButtonWidget()
    button.label = "Button"
    button.x = 20
    button.y = 40
    button.width = 100
    button.height = 80
    button.onClicked = proc() = echo "Clicked"

    let parent = newWindowWidget()
    parent.title = "Window"
    parent.x = i.float * width
    parent.y = j.float * height
    parent.width = 300
    parent.height = 200

    let child = newWindowWidget()
    child.title = "Child Window"
    child.x = 50
    child.y = 50
    child.width = 200
    child.height = 200

    parent.children.add(child)
    child.children.add(button)
    gui.children.add(parent)

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)
  gui.draw()
  canvas.render()

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()
  gui.update()
  render()