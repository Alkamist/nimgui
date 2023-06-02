{.experimental: "overloadableEnums".}

import std/times
import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

var currentContainer = gui.addWidget()
for i in 0 ..< 100:
  currentContainer = currentContainer.addWidget()

# currentContainer.isAsleep = true

let w = gui.width / 100.0
let h = gui.height / 100.0
for i in 0 ..< 100:
  for j in 0 ..< 100:
    let widget = currentContainer.addWidget()
    # widget.onPress:
    #   echo "Pressed"
    widget.position = vec2(float(i) * w, float(j) * h) + vec2(0, 18)
    widget.size = vec2(w * 0.8, h * 0.8)
    widget.drawProc = nil
    # widget.drawProc = proc(widget: Widget) =
    #   let vg = widget.gui.vg
    #   vg.beginPath()
    #   vg.rect(vec2(0, 0), widget.size)
    #   vg.fillColor = rgb(100, 100, 100)
    #   vg.fill()
    widget.drawHook:
      vg.beginPath()
      vg.rect(vec2(0, 0), self.size)
      vg.fillColor = rgb(100, 100, 100)
      vg.fill()

var frames = 0

gui.drawHook:
  frames += 1

  vg.font = "consola"
  vg.fontSize = 13.0
  vg.setTextAlign(Left, Top)
  vg.text(vec2(0, 0), $(float(frames) / cpuTime()))



# let window1Child1 = window1.body.addWidget(Window)
# window1Child1.moveButton.hookHoverOutline()
# window1Child1.body.hookHoverOutline()
# window1Child1.position = vec2(50, 50)

# let button1 = window1.addWidget(Button)
# button1.position = vec2(-100, -100)

# let window2 = gui.addWidget(Window)
# window2.moveButton.hookHoverOutline()
# window2.body.hookHoverOutline()
# window2.position = vec2(500, 50)

# let window2Child2 = window2.body.addWidget(Window)
# window2Child2.moveButton.hookHoverOutline()
# window2Child2.body.hookHoverOutline()
# window2Child2.position = vec2(50, 50)

gui.run()


# proc drawBody(button: MouseActivatedButton, color: Color) =
#   let vg = button.vg
#   vg.beginPath()
#   vg.roundedRect(button.position, button.size, 3.0)
#   vg.fillColor = color
#   vg.fill()

# proc draw(button: MouseActivatedButton) =
#   button.drawBody(button.color)
#   if button.isDown:
#     button.drawBody(rgba(0, 0, 0, 8))
#   elif button.isHovered:
#     button.drawBody(rgba(255, 255, 255, 8))

# var button = MouseActivatedButton()
# button.mb = Right
# button.color = rgb(31, 32, 34)
# button.position = vec2(50, 50)
# button.size = vec2(96, 32)
# button.sharedState = root.sharedState

# root.sharedState.onFrame = proc(widget: Widget) =
#   button.update()
#   button.draw()

# window.run()