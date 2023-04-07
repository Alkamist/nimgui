{.experimental: "overloadableEnums".}

import ./oswindow; export oswindow
import ./gfxmod; export gfxmod

type
  GuiWidget* = ref object of RootObj
    gui* {.cursor.}: Gui
    parent* {.cursor.}: GuiWidget
    children*: seq[GuiWidget]
    update*: proc(widget: GuiWidget)
    draw*: proc(widget: GuiWidget)
    dontDraw*: bool
    dontClip*: bool
    passInput*: bool
    isHovered*: bool
    wasHovered*: bool
    position*: Vec2
    size*: Vec2
    mousePosition*: Vec2

  Gui* = ref object of GuiWidget
    osWindow*: OsWindow
    gfx*: Gfx
    hovers*: seq[GuiWidget]
    storedBackgroundColor: Color

template bounds*(widget: GuiWidget): Rect2 = rect2(widget.position, widget.size)
template x*(widget: GuiWidget): float = widget.position.x
template `x=`*(widget: GuiWidget, value: float) = widget.position.x = value
template y*(widget: GuiWidget): float = widget.position.y
template `y=`*(widget: GuiWidget, value: float) = widget.position.y = value
template width*(widget: GuiWidget): float = widget.size.x
template `width=`*(widget: GuiWidget, value: float) = widget.size.x = value
template height*(widget: GuiWidget): float = widget.size.y
template `height=`*(widget: GuiWidget, value: float) = widget.size.y = value
template mouseEntered*(widget: GuiWidget): bool = widget.isHovered and not widget.wasHovered
template mouseExited*(widget: GuiWidget): bool = widget.wasHovered and not widget.isHovered

template `mouseCursorImage=`*(gui: Gui, value: CursorImage) = gui.osWindow.mouseCursorImage = value
template process*(gui: Gui): untyped = gui.osWindow.process()
template isOpen*(gui: Gui): bool = gui.osWindow.isOpen
template time*(gui: Gui): float = gui.osWindow.time
template pixelDensity*(gui: Gui): float = gui.osWindow.pixelDensity
template mouseWheel*(gui: Gui): Vec2 = gui.osWindow.mouseWheel
template mousePresses*(gui: Gui): seq[MouseButton] = gui.osWindow.mousePresses
template mouseReleases*(gui: Gui): seq[MouseButton] = gui.osWindow.mouseReleases
template mouseIsDown*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseIsDown(button)
template keyPresses*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyPresses
template keyReleases*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyReleases
template keyIsDown*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyIsDown(key)
template textInput*(gui: Gui): string = gui.osWindow.textInput
template deltaTime*(gui: Gui): float = gui.osWindow.deltaTime
# template mousePosition*(gui: Gui): Vec2 = gui.osWindow.mousePosition
template mouseDelta*(gui: Gui): Vec2 = gui.osWindow.mouseDelta
template mouseJustMoved*(gui: Gui): bool = gui.osWindow.mouseJustMoved
template mouseWheelJustMoved*(gui: Gui): bool = gui.osWindow.mouseWheelJustMoved
template mouseJustPressed*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseJustPressed(button)
template mouseJustReleased*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseJustReleased(button)
template anyMouseJustPressed*(gui: Gui): bool = gui.osWindow.anyMouseJustPressed
template anyMouseJustReleased*(gui: Gui): bool = gui.osWindow.anyMouseJustReleased
template keyJustPressed*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyJustPressed(key)
template keyJustReleased*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyJustReleased(key)
template anyKeyJustPressed*(gui: Gui): bool = gui.osWindow.anyKeyJustPressed
template anyKeyJustReleased*(gui: Gui): bool = gui.osWindow.anyKeyJustReleased
template scale*(gui: Gui): float = gui.osWindow.scale
template pixelDensityChanged*(gui: Gui): bool = gui.osWindow.pixelDensityChanged
template aspectRatio*(gui: Gui): float = gui.osWindow.aspectRatio

template updateHook*(widgetToHook: GuiWidget, code: untyped): untyped =
  let previous = widgetToHook.update
  widgetToHook.update = proc(widgetBase: GuiWidget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    let self {.inject.} = typeof(widgetToHook)(widgetBase)
    previous(widgetBase)
    code

template drawHook*(widgetToHook: GuiWidget, code: untyped): untyped =
  let previous = widgetToHook.draw
  widgetToHook.draw = proc(widgetBase: GuiWidget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    let self {.inject.} = typeof(widgetToHook)(widgetBase)
    previous(widgetBase)
    code

func addWidget*(parent: GuiWidget, T: typedesc = GuiWidget): T =
  result = T()
  result.gui = parent.gui
  result.parent = parent
  result.update = proc(widget: GuiWidget) = widget.updateChildren()
  result.draw = proc(widget: GuiWidget) = widget.drawChildren()
  parent.children.add(result)

func isHoveredIncludingChildren*(parent: GuiWidget): bool =
  if parent.isHovered:
    return true
  for child in parent.children:
    if child.isHoveredIncludingChildren:
      return true

# func mouseEnteredIncludingChildren*(parent: GuiWidget): bool =
#   if parent.mouseEntered:
#     return true
#   for child in parent.children:
#     if child.mouseEnteredIncludingChildren and not parent.wasHovered:
#       return true

# func mouseExitedIncludingChildren*(parent: GuiWidget): bool =
#   if parent.mouseExited:
#     return true
#   for child in parent.children:
#     if child.mouseExitedIncludingChildren and not parent.isHovered:
#       return true

func bringToTop*(widget: GuiWidget) =
  let parent = widget.parent
  var foundChild = false

  for i in 0 ..< parent.children.len - 1:
    if not foundChild and parent.children[i] == widget:
      foundChild = true
    if foundChild:
      parent.children[i] = parent.children[i + 1]

  if foundChild:
    parent.children[^1] = widget

func backgroundColor*(gui: Gui): Color =
  gui.storedBackgroundColor

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.osWindow.backgroundColor = color
  gui.storedBackgroundColor = color

proc updateChildren*(parent: GuiWidget) =
  let gfx = parent.gui.gfx
  for child in parent.children:
    child.wasHovered = child.isHovered
    gfx.saveState()
    gfx.translate(gfx.pixelAlign(child.position))
    if not child.dontClip:
      gfx.clip(vec2(0, 0), child.size)
    child.isHovered = child in child.gui.hovers
    child.mousePosition = parent.mousePosition - child.position
    child.update(child)
    gfx.restoreState()

proc drawChildren*(parent: GuiWidget) =
  let gfx = parent.gui.gfx
  for child in parent.children:
    if not child.dontDraw:
      gfx.saveState()
      gfx.translate(gfx.pixelAlign(child.position))
      if not child.dontClip:
        gfx.clip(vec2(0, 0), child.size)
      child.draw(child)
      gfx.restoreState()

func childMouseHitTest(parent: GuiWidget): seq[GuiWidget] =
  for child in parent.children:
    let childBounds = child.bounds
    if childBounds.contains(parent.mousePosition) or child.dontClip:
      result.add(child)
      let hitTest = child.childMouseHitTest()
      for hit in hitTest:
        result.add(hit)

func updateHovers(gui: Gui) =
  gui.hovers.setLen(0)
  let childHitTest = gui.childMouseHitTest()
  for i in countdown(childHitTest.len - 1, 0, 1):
    let hit = childHitTest[i]
    gui.hovers.add(hit)
    if not hit.passInput:
      return
  if gui.bounds.contains(gui.osWindow.mousePosition):
    gui.hovers.add(gui)

func updateInput(gui: Gui) =
  gui.position = vec2(0, 0)
  gui.size = gui.osWindow.inputState.size
  gui.mousePosition = gui.osWindow.inputState.mousePosition

proc close*(gui: Gui) =
  when defined(emscripten):
    GcUnref(gui)
  gui.osWindow.close()
  `=destroy`(gui.gfx)

proc newGui*(parentOsWindowHandle: pointer = nil): Gui =
  result = Gui()
  when defined(emscripten):
    GcRef(result)

  result.osWindow = newOsWindow(parentOsWindowHandle)
  result.gfx = newGfx()
  result.gui = result
  result.update = proc(widget: GuiWidget) = widget.updateChildren()
  result.draw = proc(widget: GuiWidget) = widget.drawChildren()

  let gui = result
  result.osWindow.onFrame = proc() =
    let gfx = gui.gfx
    gfx.beginFrame(gui.osWindow.sizePixels, gui.osWindow.pixelDensity)
    gfx.resetClip()

    gui.updateInput()
    gui.updateHovers()
    gui.wasHovered = gui.isHovered
    gui.isHovered = gui in gui.hovers

    gui.update(gui)
    gui.draw(gui)

    gfx.endFrame(gui.osWindow.sizePixels)