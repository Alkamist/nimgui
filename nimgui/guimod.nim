{.experimental: "overloadableEnums".}

import ./math; export math
import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  Widget* = ref object of RootObj
    gui* {.cursor.}: Gui
    parent* {.cursor.}: Widget
    children*: seq[Widget]
    position*: Vec2
    size*: Vec2

  Gui* = ref object
    osWindow*: OsWindow
    renderer*: DrawListRenderer
    drawList*: DrawList
    root*: Widget
    hover*: Widget
    storedBackgroundColor: Color

template update*(gui: Gui) = gui.osWindow.update()
template isOpen*(gui: Gui): bool = gui.osWindow.isOpen
template time*(gui: Gui): float = gui.osWindow.time
template isFocused*(gui: Gui): bool = gui.osWindow.isFocused
template isHovered*(gui: Gui): bool = gui.osWindow.isHovered
template pixelDensity*(gui: Gui): float = gui.osWindow.pixelDensity
template boundsPixels*(gui: Gui): Rect2 = gui.osWindow.boundsPixels
template mousePositionPixels*(gui: Gui): Vec2 = gui.osWindow.mousePositionPixels
template mouseWheel*(gui: Gui): Vec2 = gui.osWindow.mouseWheel
template mousePresses*(gui: Gui): seq[MouseButton] = gui.osWindow.mousePresses
template mouseReleases*(gui: Gui): seq[MouseButton] = gui.osWindow.mouseReleases
template mouseDown*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseDown(button)
template keyPresses*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyPresses
template keyReleases*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyReleases
template keyDown*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyDown(key)
template text*(gui: Gui): string = gui.osWindow.text
template deltaTime*(gui: Gui): float = gui.osWindow.deltaTime
template mousePosition*(gui: Gui): Vec2 = gui.osWindow.mousePosition
template mouseDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.mouseDeltaPixels
template mouseDelta*(gui: Gui): Vec2 = gui.osWindow.mouseDelta
template mouseMoved*(gui: Gui): bool = gui.osWindow.mouseMoved
template mouseWheelMoved*(gui: Gui): bool = gui.osWindow.mouseWheelMoved
template mousePressed*(gui: Gui, button: MouseButton): bool = gui.osWindow.mousePressed(button)
template mouseReleased*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseReleased(button)
template anyMousePressed*(gui: Gui): bool = gui.osWindow.anyMousePressed
template anyMouseReleased*(gui: Gui): bool = gui.osWindow.anyMouseReleased
template keyPressed*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyPressed(key)
template keyReleased*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyReleased(key)
template anyKeyPressed*(gui: Gui): bool = gui.osWindow.anyKeyPressed
template anyKeyReleased*(gui: Gui): bool = gui.osWindow.anyKeyReleased
template bounds*(gui: Gui): Rect2 = gui.osWindow.bounds
template positionPixels*(gui: Gui): Vec2 = gui.osWindow.positionPixels
template xPixels*(gui: Gui): float = gui.osWindow.xPixels
template yPixels*(gui: Gui): float = gui.osWindow.yPixels
template position*(gui: Gui): Vec2 = gui.osWindow.position
template x*(gui: Gui): float = gui.osWindow.x
template y*(gui: Gui): float = gui.osWindow.y
template sizePixels*(gui: Gui): Vec2 = gui.osWindow.sizePixels
template widthPixels*(gui: Gui): float = gui.osWindow.widthPixels
template heightPixels*(gui: Gui): float = gui.osWindow.heightPixels
template size*(gui: Gui): Vec2 = gui.osWindow.size
template width*(gui: Gui): float = gui.osWindow.width
template height*(gui: Gui): float = gui.osWindow.height
template scale*(gui: Gui): float = gui.osWindow.scale
template moved*(gui: Gui): bool = gui.osWindow.moved
template positionDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.positionDeltaPixels
template positionDelta*(gui: Gui): Vec2 = gui.osWindow.positionDelta
template resized*(gui: Gui): bool = gui.osWindow.resized
template sizeDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.sizeDeltaPixels
template sizeDelta*(gui: Gui): Vec2 = gui.osWindow.sizeDelta
template pixelDensityChanged*(gui: Gui): bool = gui.osWindow.pixelDensityChanged
template aspectRatio*(gui: Gui): float = gui.osWindow.aspectRatio
template gainedFocus*(gui: Gui): bool = gui.osWindow.gainedFocus
template lostFocus*(gui: Gui): bool = gui.osWindow.lostFocus
template mouseEntered*(gui: Gui): bool = gui.osWindow.mouseEntered
template mouseExited*(gui: Gui): bool = gui.osWindow.mouseExited

method initialize*(widget: Widget) {.base.} = discard
method update*(widget: Widget) {.base.} = discard
method draw*(widget: Widget) {.base.} = discard

# template position*(widget: Widget): auto = widget.bounds.position
# template `position=`*(widget: Widget, value: Vec2): auto = widget.position.size = value
template x*(widget: Widget): auto = widget.position.x
template `x=`*(widget: Widget, value: float) = widget.position.x = value
template y*(widget: Widget): auto = widget.position.y
template `y=`*(widget: Widget, value: float) = widget.position.y = value
# template size*(widget: Widget): auto = widget.bounds.size
# template `size=`*(widget: Widget, value: Vec2): auto = widget.bounds.size = value
template width*(widget: Widget): auto = widget.size.x
template `width=`*(widget: Widget, value: float) = widget.size.x = value
template height*(widget: Widget): auto = widget.size.y
template `height=`*(widget: Widget, value: float) = widget.size.y = value

template drawList*(widget: Widget): DrawList = widget.gui.drawList
template isHovered*(widget: Widget): bool = widget.gui.hover == widget

func isHoveredIncludingChildren*(widget: Widget): bool =
  if widget.isHovered:
    return true
  for child in widget.children:
    if child.isHovered:
      return true

func absolutePosition*(widget: Widget): Vec2 =
  if widget.parent == nil:
    widget.position
  else:
    widget.position + widget.parent.absolutePosition

func mousePosition*(widget: Widget): Vec2 =
  widget.gui.mousePosition - widget.absolutePosition

func bringToTop*(widget: Widget) =
  let parent = widget.parent

  var found = false
  for i in 0 ..< parent.children.len - 1:
    if not found and parent.children[i] == widget:
      found = true
    if found:
      parent.children[i] = parent.children[i + 1]

  if found:
    parent.children[^1] = widget

func hover*(widget: Widget): Widget =
  for i in countdown(widget.children.len - 1, 0, 1):
    let child = widget.children[i]
    let bounds = rect2(vec2(0, 0), child.size)
    if bounds.contains(child.mousePosition):
      let hoverOfChild = child.hover
      if hoverOfChild == nil:
        return child
      else:
        return hoverOfChild

func addWidget*(widget: Widget, T: typedesc): T =
  let child = T()
  child.gui = widget.gui
  child.parent = widget
  child.initialize()
  widget.children.add child
  child

func backgroundColor*(gui: Gui): Color =
  gui.storedBackgroundColor

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.osWindow.backgroundColor = color
  gui.storedBackgroundColor = color

proc newGui*(): Gui =
  result = Gui()
  result.osWindow = newOsWindow()
  result.renderer = newDrawListRenderer()
  result.drawList = newDrawList()
  result.root = Widget()
  result.root.gui = result

proc beginFrame*(gui: Gui) =
  gui.renderer.beginFrame(gui.sizePixels, gui.pixelDensity)
  gui.drawList.clearCommands()
  gui.root.size = gui.size
  gui.hover = gui.root.hover

proc endFrame*(gui: Gui) =
  for child in gui.root.children:
    child.update()
  for child in gui.root.children:
    child.draw()
  gui.drawList.resetTransform()
  gui.renderer.render(gui.drawList)
  gui.renderer.endFrame(gui.sizePixels)

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()