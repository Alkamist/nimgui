{.experimental: "overloadableEnums".}

import nimgui
import nimgui/imploswindow
import nimgui/widgets
import oswindow as oswnd

let osWindow = OsWindow.new()
osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
osWindow.show()

let gui = Gui.new()
gui.attachToOsWindow(osWindow)

# proc outline(gui: Gui, bounds: Rect2, color: Color) =
#   let vg = gui.vg
#   vg.beginPath()
#   vg.rect(bounds.expand(-0.5))
#   vg.strokeColor = color
#   vg.stroke()

# proc debugBounds(gui: Gui, color = rgb(255, 255, 255)): Rect2 {.discardable.} =
#   result = gui.getNextBounds()
#   gui.outline(result, color)

proc testWidget(gui: Gui, id: auto) =
  gui.pushLayout(gui.getNextBounds())
  gui.pushId(id)
  gui.rowHeight = 32
  gui.rowWidths = [16, 32, -1]
  if gui.button("Button1").clicked: echo "Button 1 Clicked"
  if gui.button("Button2").clicked: echo "Button 2 Clicked"
  gui.popId()
  gui.popLayout()

osWindow.onFrame = proc(osWindow: OsWindow) =
  gui.time = osWindow.time
  gui.beginFrame()

  let width = gui.splitWidth(3)

  gui.rowHeight = gui.splitHeight(2)
  gui.rowWidths = [width, width]

  if gui.button("Button1").clicked: echo "Button 1 Clicked"
  if gui.button("Button2").clicked: echo "Button 2 Clicked"

  if gui.button("Button3").clicked: echo "Button 3 Clicked"
  if gui.button("Button4").clicked: echo "Button 4 Clicked"

  # gui.testWidget("1")
  # gui.testWidget("2")
  # gui.testWidget("3")

  gui.endFrame()

  if osWindow.isHovered:
    osWindow.setCursorStyle(gui.cursorStyle)

  osWindow.swapBuffers()

osWindow.run()