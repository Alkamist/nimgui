{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets
import nimgui/backends

const fontData = readFile("consola.ttf")

const sampleText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed consectetur metus et porta elementum.
Donec eget feugiat velit, in tincidunt velit.
Mauris et porta turpis, fringilla dapibus dolor.
Vestibulum vulputate faucibus velit, a facilisis tellus egestas eu.
Nullam ultricies sem vitae nisi finibus, elementum sollicitudin turpis placerat.
Curabitur ultricies ante scelerisque placerat fermentum.
Maecenas mattis dui eros, eget faucibus leo feugiat quis.
Nunc ultricies, enim a euismod tempus, risus erat rutrum diam, sed iaculis elit sapien at ante.
Nam vulputate arcu et bibendum aliquet. Nulla eget urna ligula.
Proin sollicitudin cursus enim, eu suscipit odio suscipit vitae.
Pellentesque a turpis nulla."""

let gui = Gui.new()
gui.backgroundColor = rgb(49, 51, 56)

gui.setupBackend()
gui.addFont(fontData)
gui.show()

type
  ExampleWindow = ref object of Window
    title: Text
    slider: Slider
    text: Text
    textScroll: Vec2

proc init(window: ExampleWindow) =
  Window(window).init()
  window.title = gui.newWidget(Text)
  window.slider = gui.newWidget(Slider)
  window.text = gui.newWidget(Text)
  window.text.data = sampleText

proc beginUpdate(window: ExampleWindow) =
  const padding = vec2(5.0, 5.0)

  Window(window).beginUpdate()

  let header = window.beginHeader()

  let title = window.title
  title.size = header.size
  title.alignment = vec2(0.5, 0.5)
  title.update()

  window.endHeader()

  let body = window.beginBody(padding)

  let slider = window.slider
  slider.size = vec2(body.size.x, 24)

  let text = window.text
  text.position = vec2(0, slider.size.y + padding.y)
  text.size = vec2(body.size.x, body.size.y - text.position.y)
  text.alignment = vec2(slider.value, 0)

  if gui.mouseHitTest(text.position, text.size):
    gui.requestHover(text)

  if gui.isHovered(text) and gui.mouseWheelMoved:
    window.textScroll.y += gui.mouseWheel.y * 32.0

  gui.beginClipRect(text.position, text.size)
  gui.beginOffset(window.textScroll)
  text.update()
  gui.endOffset()
  gui.endClipRect()

  slider.update()

  window.endBody()

proc endUpdate(window: ExampleWindow) =
  Window(window).endUpdate()

let performance = gui.newWidget(Performance)
let fpsText = gui.newWidget(Text)

let window1 = gui.newWidget(ExampleWindow)
window1.title.data = "Window 1"
window1.position = vec2(50, 50)

let window2 = gui.newWidget(ExampleWindow)
window2.title.data = "Window 2"
window2.position = vec2(600, 50)

let window3 = gui.newWidget(ExampleWindow)
window3.title.data = "Window 3"
window3.position = vec2(50, 400)

let window4 = gui.newWidget(ExampleWindow)
window4.title.data = "Window 4"
window4.position = vec2(600, 400)

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  window1.beginUpdate()
  window1.endUpdate()

  window2.beginUpdate()
  window2.endUpdate()

  window3.beginUpdate()
  window3.endUpdate()

  window4.beginUpdate()
  window4.endUpdate()

  performance.update()
  fpsText.data = "Fps: " & performance.fps.formatFloat(ffDecimal, 4)
  fpsText.update()

  gui.endFrame()

gui.run()