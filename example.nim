{.experimental: "overloadableEnums".}

import nimgui

let gui = Gui.new()

const consolaData = readFile("consola.ttf")
gui.vg.addFont("consola", consolaData)

proc hookHoverOutline(widget: Widget) =
  widget.drawHook:
    if self.isHovered:
      vg.beginPath()
      vg.rect(vec2(0, 0), self.size)
      vg.strokeColor = rgb(0, 255, 0)
      vg.stroke()

let window1 = gui.addWidget(Window)
window1.moveButton.hookHoverOutline()
window1.body.hookHoverOutline()
window1.position = vec2(50, 50)

let window1Child1 = window1.body.addWidget(Window)
window1Child1.moveButton.hookHoverOutline()
window1Child1.body.hookHoverOutline()
window1Child1.position = vec2(50, 50)

let button1 = window1.addWidget(Button)
button1.position = vec2(-100, -100)

let window2 = gui.addWidget(Window)
window2.moveButton.hookHoverOutline()
window2.body.hookHoverOutline()
window2.position = vec2(500, 50)

let window2Child2 = window2.body.addWidget(Window)
window2Child2.moveButton.hookHoverOutline()
window2Child2.body.hookHoverOutline()
window2Child2.position = vec2(50, 50)

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