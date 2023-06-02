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

# let w = gui.width / 10.0
# let h = gui.height / 10.0
# for i in 0 ..< 10:
#   for j in 0 ..< 10:
#     let window = gui.addWidget(Window)
#     # window.moveButton.hookHoverOutline()
#     # window.body.hookHoverOutline()
#     window.position = vec2(float(i) * w, float(j) * h)
#     window.size = vec2(w, h)

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