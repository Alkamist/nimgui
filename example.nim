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
  ExampleWindowState = object
    position: Vec2
    size: Vec2
    textScroll: Vec2
    sliderValue: float

proc exampleWindow(gui: Gui, title: string, initialPosition: Vec2) =
  let id = gui.getId(title)
  gui.pushIdSpace(id)

  const padding = vec2(5.0, 5.0)

  var (state, stateRef) = gui.getState(gui.getId("State"), ExampleWindowState(
    position: initialPosition,
    size: vec2(400, 300),
  ))

  gui.beginWindow(gui.getId("Window"), state.position, state.size)

  # Header
  let header = gui.beginWindowHeader()
  gui.fillText(title, vec2(0, 0), header.size, alignment = vec2(0.5, 0.5))
  gui.endWindowHeader()

  # Body
  let body = gui.beginWindowBody(padding)

  # Slider
  let sliderSize = vec2(body.size.x, 24)
  gui.slider(gui.getId("Slider"), state.sliderValue, size = sliderSize)

  # Text
  let textPosition = vec2(0, sliderSize.y + padding.y)
  let textSize = vec2(body.size.x, body.size.y - textPosition.y)

  let textInteractionId = gui.getId("TextInteraction")
  if gui.mouseHitTest(textPosition, textSize):
    gui.requestHover(textInteractionId)

  if gui.isHovered(textInteractionId) and gui.mouseWheelMoved:
    state.textScroll.y += gui.mouseWheel.y * 32.0

  gui.pushClipRect(textPosition, textSize)
  gui.fillText(sampleText, textPosition + state.textScroll, textSize, alignment = vec2(state.sliderValue, 0))
  gui.popClipRect()

  gui.endWindowBody()
  gui.endWindow()

  stateRef.state = state

  gui.popIdSpace()

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  gui.exampleWindow("Window1", vec2(50, 50))
  gui.exampleWindow("Window2", vec2(600, 50))
  gui.exampleWindow("Window3", vec2(50, 400))
  gui.exampleWindow("Window4", vec2(600, 400))

  gui.fillTextRaw("Fps: " & gui.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

gui.run()