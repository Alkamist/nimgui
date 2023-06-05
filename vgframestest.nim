{.experimental: "overloadableEnums".}

import nimgui/math
import std/times
import oswindow
import vectorgraphics

let window = OsWindow.new()
window.show()

let vg = VectorGraphics.new()
const consolaData = readFile("consola.ttf")
vg.addFont("consola", consolaData)

var frames = 0

window.onFrame = proc(window: OsWindow) =
  frames += 1

  let (pixelWidth, pixelHeight) = window.size
  vg.beginFrame(pixelWidth, pixelHeight, 1.0)

  let w = float(pixelWidth) / 100.0
  let h = float(pixelHeight) / 100.0
  for i in 0 ..< 100:
    for j in 0 ..< 100:
      let position = vec2(float(i) * w, float(j) * h) + vec2(0, 18)
      let size = vec2(w * 0.8, h * 0.8)
      vg.saveState()
      vg.translate(vec2(0, 0))
      vg.beginPath()
      vg.rect(position, size)
      vg.fillColor = rgb(100, 100, 100)
      vg.fill()
      vg.restoreState()

  vg.fillColor = rgb(255, 255, 255)
  vg.font = "consola"
  vg.fontSize = 13.0
  vg.textAlign(Left, Top)
  vg.text(vec2(0, 0), $(float(frames) / cpuTime()))

  vg.endFrame()
  window.swapBuffers()

window.run()