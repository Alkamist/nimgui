{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets

const sampleText = """
An preost wes on leoden, Laȝamon was ihoten

He wes Leovenaðes sone -- liðe him be Drihten.

He wonede at Ernleȝe at æðelen are chirechen,

Uppen Sevarne staþe, sel þar him þuhte,

Onfest Radestone, þer he bock radde."""

# const sampleText = """
# Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed consectetur metus et porta elementum. Donec eget feugiat velit, in tincidunt velit. Mauris et porta turpis, fringilla dapibus dolor. Vestibulum vulputate faucibus velit, a facilisis tellus egestas eu. Nullam ultricies sem vitae nisi finibus, elementum sollicitudin turpis placerat. Curabitur ultricies ante scelerisque placerat fermentum. Maecenas mattis dui eros, eget faucibus leo feugiat quis. Nunc ultricies, enim a euismod tempus, risus erat rutrum diam, sed iaculis elit sapien at ante. Nam vulputate arcu et bibendum aliquet. Nulla eget urna ligula. Proin sollicitudin cursus enim, eu suscipit odio suscipit vitae. Pellentesque a turpis nulla.

# Morbi cursus condimentum nisl, quis pulvinar mauris feugiat id. Ut non ipsum tempor, dapibus libero nec, molestie purus. Proin vitae dui odio. Proin tristique ipsum sit amet felis varius egestas. Curabitur finibus massa fringilla, dictum eros quis, aliquet metus. Integer condimentum ipsum eget nibh hendrerit, in fermentum ligula hendrerit. Fusce scelerisque eu velit eu feugiat. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Morbi lectus dui, gravida in semper at, semper a urna.

# Nam eu porttitor lectus, in sagittis lorem. Morbi vel ex vel erat rutrum imperdiet. Ut porttitor, nisi quis imperdiet faucibus, turpis elit posuere erat, at ullamcorper mi nisi tincidunt dui. Aenean gravida, dolor quis sagittis accumsan, urna purus fringilla dolor, nec mattis diam arcu at lorem. Mauris suscipit lacus non ligula placerat, a iaculis leo commodo. Aliquam nec nisl pretium, dignissim risus sit amet, viverra nunc. Donec eget venenatis ante. Nullam sollicitudin eros semper commodo rutrum. Integer ultricies ex ac magna fringilla tempus. Donec pulvinar at enim ut elementum.

# Nam vel sagittis lorem. Donec pretium et nisi eget vehicula. Maecenas feugiat felis sit amet libero dapibus bibendum. Proin fringilla ligula tellus, ac euismod leo pretium vel. Aenean viverra, tortor nec tristique tincidunt, purus massa euismod enim, ut fringilla felis velit in mi. Nullam hendrerit urna a odio ullamcorper iaculis. Donec tempus laoreet neque, eget condimentum ligula tempor a. Nunc tempus pellentesque tellus et porttitor. Nulla sollicitudin sem tellus, vitae egestas leo suscipit eget. In viverra vestibulum elit, at ornare nulla dictum vitae. Sed elementum feugiat purus, at interdum mauris consequat non.

# Maecenas maximus lacinia orci, ac pharetra eros tincidunt et. Ut vel eleifend elit. Quisque ac accumsan nisl. In erat velit, eleifend nec ultrices dictum, pretium eget dui. Nullam posuere massa est, et condimentum nisi consectetur nec. Fusce euismod quis nisl ac finibus. Donec sed ornare neque. Duis pretium, neque euismod egestas scelerisque, elit tortor faucibus quam, quis tristique ex ante sit amet risus. Mauris cursus iaculis nulla eget placerat."""

# var sampleLine = ""
# for i in 0 ..< 100:
#   sampleLine &= "ABCD "

# var sampleText = ""
# for i in 0 ..< 1000:
#   sampleText &= sampleLine & '\n'

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let root = GuiRoot.new()
root.attachToOsWindow(osWindow)

const fontData = readFile("consola.ttf")
root.addFont(fontData)

var performance = Performance()

type
  ExampleWindow = ref object of Window

proc getExampleWindow(node: GuiNode, id: string): ExampleWindow =
  result = node.getNode(id, ExampleWindow)
  if result.init:
    result.setDefault()

proc update(window: ExampleWindow) =
  Window(window).update()

  const padding = 10.0

  let slider = window.body.getSlider("Slider")
  slider.position = vec2(padding, padding)
  slider.size.x = slider.parent.size.x - padding * 2
  slider.update()

  let childWindow = window.getWindow("ChildWindow")
  if childWindow.init:
    childWindow.position = vec2(100, 100)

  childWindow.update()

  let childWindowBody = childWindow.body

  let button = childWindowBody.getButton("Button")
  button.update()

  if button.clicked:
    slider.value = slider.value + 0.05

  button.position = vec2(padding + slider.value * (childWindowBody.size.x - button.size.x - padding * 2), padding)

  let text = childWindowBody.getText("Text")
  if text.init:
    text.clipChildren = false
    text.data = sampleText
    text.color = rgb(255, 255, 0)
    text.wordWrap = true
    text.size = vec2(300, 300)
    text.fontSize = 13.0

  # text.position = vec2(
  #   padding,
  #   button.size.y + padding * 2,
  # )
  # text.size = vec2(
  #   childWindowBody.size.x - padding * 2,
  #   childWindowBody.size.y - padding - text.position.y,
  # )
  if text.mouseDown(Middle) and text.mouseMoved:
    if text.keyDown(LeftShift):
      text.size.x += text.mouseDelta.x
    else:
      text.position += text.mouseDelta

  text.alignment = slider.value
  text.update()

  let textOutline = Path.new()
  textOutline.roundedRect(vec2(0.5, 0.5), text.size - vec2(-1.0, -1.0), 3)
  text.strokePath(textOutline, rgb(0, 255, 0))

  # for line in text.lines:
  #   if line.glyphs.len == 0: continue
  #   let lineOutline = Path.new()
  #   lineOutline.rect(line.position + vec2(0.5, 0.5), line.size - vec2(-1.0, -1.0))
  #   text.strokePath(lineOutline, rgb(255, 0, 0))

  # for line in text.lines:
  #   for glyph in line.glyphs:
  #     let glyphOutline = Path.new()
  #     glyphOutline.rect(
  #       line.position + vec2(glyph.left + 0.5, 0.5),
  #       vec2(glyph.right - glyph.left - 1.0, line.height - 1.0),
  #     )
  #     text.strokePath(glyphOutline, rgb(255, 0, 0))

osWindow.onFrame = proc(osWindow: OsWindow) =
  root.time = osWindow.time
  root.beginFrame()

  # let window1 = root.getExampleWindow("Window1")
  # if window1.init:
  #   window1.position = vec2(100, 100)

  # window1.update()

  let window2 = root.getExampleWindow("Window2")
  if window2.init:
    window2.position = vec2(600, 100)

  window2.update()

  performance.update(root.deltaTime)
  # let fps = root.getText("Fps")
  # fps.data = "Fps: " & performance.fps.formatFloat(ffDecimal, 4)
  # fps.update()

  root.fillTextRaw("Fps: " & performance.fps.formatFloat(ffDecimal, 4), vec2(0, 0), rgb(255, 255, 255), 0, 13)

  root.endFrame()

  osWindow.swapBuffers()

osWindow.run()