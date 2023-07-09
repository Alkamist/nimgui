{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

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
Pellentesque a turpis nulla.

Morbi cursus condimentum nisl, quis pulvinar mauris feugiat id.
Ut non ipsum tempor, dapibus libero nec, molestie purus.
Proin vitae dui odio.
Proin tristique ipsum sit amet felis varius egestas.
Curabitur finibus massa fringilla, dictum eros quis, aliquet metus.
Integer condimentum ipsum eget nibh hendrerit, in fermentum ligula hendrerit.
Fusce scelerisque eu velit eu feugiat.
Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
Morbi lectus dui, gravida in semper at, semper a urna.

Nam eu porttitor lectus, in sagittis lorem.
Morbi vel ex vel erat rutrum imperdiet.
Ut porttitor, nisi quis imperdiet faucibus, turpis elit posuere erat, at ullamcorper mi nisi tincidunt dui.
Aenean gravida, dolor quis sagittis accumsan, urna purus fringilla dolor, nec mattis diam arcu at lorem.
Mauris suscipit lacus non ligula placerat, a iaculis leo commodo.
Aliquam nec nisl pretium, dignissim risus sit amet, viverra nunc.
Donec eget venenatis ante.
Nullam sollicitudin eros semper commodo rutrum.
Integer ultricies ex ac magna fringilla tempus.
Donec pulvinar at enim ut elementum.

Nam vel sagittis lorem.
Donec pretium et nisi eget vehicula.
Maecenas feugiat felis sit amet libero dapibus bibendum.
Proin fringilla ligula tellus, ac euismod leo pretium vel.
Aenean viverra, tortor nec tristique tincidunt, purus massa euismod enim, ut fringilla felis velit in mi.
Nullam hendrerit urna a odio ullamcorper iaculis.
Donec tempus laoreet neque, eget condimentum ligula tempor a.
Nunc tempus pellentesque tellus et porttitor.
Nulla sollicitudin sem tellus, vitae egestas leo suscipit eget.
In viverra vestibulum elit, at ornare nulla dictum vitae.
Sed elementum feugiat purus, at interdum mauris consequat non.

Maecenas maximus lacinia orci, ac pharetra eros tincidunt et.
Ut vel eleifend elit. Quisque ac accumsan nisl.
In erat velit, eleifend nec ultrices dictum, pretium eget dui.
Nullam posuere massa est, et condimentum nisi consectetur nec.
Fusce euismod quis nisl ac finibus.
Donec sed ornare neque.
Duis pretium, neque euismod egestas scelerisque, elit tortor faucibus quam, quis tristique ex ante sit amet risus.
Mauris cursus iaculis nulla eget placerat."""

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
gui.addFont(fontData)

proc exampleWindow(gui: Gui, name: string, initialPosition: Vec2) =
  gui.pushIdSpace(gui.getId(name))

  const padding = 5.0
  const spacing = 5.0

  let positionId = gui.getId("Position")
  var position = gui.getState(positionId, initialPosition)

  let sizeId = gui.getId("Size")
  var size = gui.getState(sizeId, vec2(400, 300))

  gui.beginWindow("Window", position, size)

  # Header
  let header = gui.beginWindowHeader()
  gui.fillText(name, vec2(0, 0), header.size, alignment = vec2(0.5, 0.5))
  gui.endWindowHeader()

  # Body
  let body = gui.beginWindowBody()

  let sliderValueId = gui.getId("SliderValue")
  var sliderValue = gui.getState(sliderValueId, 0.0)
  let sliderPosition = vec2(padding, padding)
  let sliderSize = vec2(body.size.x - padding * 2.0, 24)
  gui.slider("Slider", sliderValue, sliderPosition, sliderSize)
  gui.setState(sliderValueId, sliderValue)

  let textScrollId = gui.getId("TextScroll")
  var textScroll = gui.getState(textScrollId, vec2(0, 0))
  let textPosition = vec2(sliderPosition.x, sliderPosition.y + sliderSize.y + spacing)
  let textSize = vec2(body.size.x - padding * 2.0, body.size.y - textPosition.y - padding)

  let textInteractionId = gui.getId("TextInteraction")
  if gui.mouseHitTest(textPosition, textSize):
    gui.requestHover(textInteractionId)

  if gui.isHovered(textInteractionId) and gui.mouseWheelMoved:
    textScroll.y += gui.mouseWheel.y * 32.0

  gui.pushClipRect(textPosition, textSize)
  gui.fillText(sampleText, textPosition + textScroll, textSize, alignment = vec2(sliderValue, 0))
  gui.popClipRect()

  gui.setState(textScrollId, textScroll)

  gui.endWindowBody()

  gui.endWindow()

  gui.setState(positionId, position)
  gui.setState(sizeId, size)

  gui.popIdSpace()

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  gui.exampleWindow("Window1", vec2(50, 50))
  gui.exampleWindow("Window2", vec2(600, 50))
  gui.exampleWindow("Window3", vec2(50, 400))
  gui.exampleWindow("Window4", vec2(600, 400))

  gui.fillTextRaw("Fps: " & gui.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

  osWindow.swapBuffers()

osWindow.run()