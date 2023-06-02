{.experimental: "overloadableEnums".}

import std/times
import std/strformat
import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

var frames = 0

gui.run:
  frames += 1

  let w = gui.width / 100.0
  let h = gui.height / 100.0
  for i in 0 ..< 100:
    for j in 0 ..< 100:
      gui.button(button[j * 100 + i]):
        button.x = float(i) * w
        button.y = float(j) * h + 15
        button.width = w * 0.8
        button.height = h * 0.8

        button.press:
          gui.mousePressed(Left)

        button.release:
          gui.mouseReleased(Left)

        button.onPress:
          echo &"Pressed {button.id}"

        button.onRelease:
          echo &"Released {button.id}"

        button.draw:
          vg.beginPath()
          vg.rect(vec2(0, 0), button.size)
          vg.fillColor = rgb(100, 100, 100)
          vg.fill()

  vg.fillColor = rgb(255, 255, 255)
  vg.font = "consola"
  vg.fontSize = 13.0
  vg.setTextAlign(Left, Top)
  vg.text(vec2(0, 0), $(float(frames) / cpuTime()))