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
Nam vulputate arcu et bibendum aliquet.
Nulla eget urna ligula.
Proin sollicitudin cursus enim, eu suscipit odio suscipit vitae.
Pellentesque a turpis nulla."""

let gui = Gui.new()
gui.backgroundColor = rgb(49, 51, 56)

gui.setupBackend()
gui.addFont(fontData)
gui.show()

let performance = Performance.new()

let slider = Slider.new()
slider.position = vec2(100, 50)

let text = Text.new()
text.position = vec2(100, 100)
text.size = vec2(400, 300)
text.data = sampleText

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  gui.update(slider)
  gui.draw(slider)

  text.alignment.x = slider.value
  gui.update(text)

  let path = Path.new()
  path.rect(text.position + vec2(0.5, 0.5), text.size - vec2(1.0, 1.0))
  gui.strokePath(path, rgb(0, 255, 0))

  gui.update(performance)
  gui.fillTextLine("Fps: " & performance.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

  gui.endFrame()

gui.run()