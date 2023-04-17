{.experimental: "overloadableEnums".}

import ./gfxmod; export gfxmod

type
  MouseCursorStyle* = enum
    Arrow
    IBeam
    Crosshair
    PointingHand
    ResizeLeftRight
    ResizeTopBottom
    ResizeTopLeftBottomRight
    ResizeTopRightBottomLeft

  MouseButton* = enum
    Unknown,
    Left, Middle, Right,
    Extra1, Extra2, Extra3,
    Extra4, Extra5,

  KeyboardKey* = enum
    Unknown,
    A, B, C, D, E, F, G, H, I,
    J, K, L, M, N, O, P, Q, R,
    S, T, U, V, W, X, Y, Z,
    Key1, Key2, Key3, Key4, Key5,
    Key6, Key7, Key8, Key9, Key0,
    Pad1, Pad2, Pad3, Pad4, Pad5,
    Pad6, Pad7, Pad8, Pad9, Pad0,
    F1, F2, F3, F4, F5, F6, F7,
    F8, F9, F10, F11, F12,
    Backtick, Minus, Equal, Backspace,
    Tab, CapsLock, Enter, LeftShift,
    RightShift, LeftControl, RightControl,
    LeftAlt, RightAlt, LeftMeta, RightMeta,
    LeftBracket, RightBracket, Space,
    Escape, Backslash, Semicolon, Quote,
    Comma, Period, Slash, ScrollLock,
    Pause, Insert, End, PageUp, Delete,
    Home, PageDown, LeftArrow, RightArrow,
    DownArrow, UpArrow, NumLock, PadDivide,
    PadMultiply, PadSubtract, PadAdd, PadEnter,
    PadPeriod, PrintScreen,

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
    previousPosition*: Vec2
    size*: Vec2
    previousSize*: Vec2
    mousePosition*: Vec2

  Gui* = ref object of GuiWidget
    gfx*: Gfx
    justCreated*: bool
    hovers*: seq[GuiWidget]
    mouseCapture*: GuiWidget
    mouseDelta*: Vec2
    time*: float
    previousTime*: float
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string
    mouseCursorStyle*: MouseCursorStyle
    previousMouseCursorStyle*: MouseCursorStyle
    backgroundColor*: Color
    previousBackgroundColor*: Color

template bounds*(widget: GuiWidget): Rect2 = rect2(widget.position, widget.size)
template x*(widget: GuiWidget): float = widget.position.x
template `x=`*(widget: GuiWidget, value: float) = widget.position.x = value
template y*(widget: GuiWidget): float = widget.position.y
template `y=`*(widget: GuiWidget, value: float) = widget.position.y = value
template width*(widget: GuiWidget): float = widget.size.x
template `width=`*(widget: GuiWidget, value: float) = widget.size.x = value
template height*(widget: GuiWidget): float = widget.size.y
template `height=`*(widget: GuiWidget, value: float) = widget.size.y = value
template justMoved*(widget: GuiWidget): bool = widget.position != widget.previousPosition
template justResized*(widget: GuiWidget): bool = widget.size != widget.previousSize
template mouseEntered*(widget: GuiWidget): bool = widget.isHovered and not widget.wasHovered
template mouseExited*(widget: GuiWidget): bool = widget.wasHovered and not widget.isHovered

template deltaTime*(gui: Gui): float = gui.time - gui.previousTime
template backgroundColorChanged*(gui: Gui): bool = gui.backgroundColor != gui.previousBackgroundColor
template mouseCursorStyleChanged*(gui: Gui): bool = gui.mouseCursorStyle != gui.previousMouseCursorStyle
template mouseIsDown*(gui: Gui, button: MouseButton): bool = gui.mouseDownStates[button]
template keyIsDown*(gui: Gui, key: KeyboardKey): bool = gui.keyDownStates[key]
template mouseJustMoved*(gui: Gui): bool = gui.mouseDelta != vec2(0, 0)
template mouseWheelJustMoved*(gui: Gui): bool = gui.mouseWheel != vec2(0, 0)
template mouseJustPressed*(gui: Gui, button: MouseButton): bool = button in gui.mousePresses
template mouseJustReleased*(gui: Gui, button: MouseButton): bool = button in gui.mouseReleases
template anyMouseJustPressed*(gui: Gui): bool = gui.mousePresses.len > 0
template anyMouseJustReleased*(gui: Gui): bool = gui.mouseReleases.len > 0
template keyJustPressed*(gui: Gui, key: KeyboardKey): bool = key in gui.keyPresses
template keyJustReleased*(gui: Gui, key: KeyboardKey): bool = key in gui.keyReleases
template anyKeyJustPressed*(gui: Gui): bool = gui.keyPresses.len > 0
template anyKeyJustReleased*(gui: Gui): bool = gui.keyReleases.len > 0

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

proc updateChildren*(parent: GuiWidget) =
  let gfx = parent.gui.gfx
  for child in parent.children:
    child.previousPosition = child.position
    child.previousSize = child.size
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
  let mouseCapture = parent.gui.mouseCapture
  for child in parent.children:
    let childBounds = child.bounds
    let mouseInside = childBounds.contains(parent.mousePosition) or child.dontClip
    let noCapture = mouseCapture == nil
    let captureAndIsChild = mouseCapture != nil and mouseCapture == child
    if (noCapture and mouseInside) or (captureAndIsChild and mouseInside):
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
  if gui.bounds.contains(gui.mousePosition):
    gui.hovers.add(gui)

proc process*(gui: Gui, widthPixels, heightPixels: int, pixelDensity: float) =
  gui.previousMouseCursorStyle = gui.mouseCursorStyle
  gui.previousBackgroundColor = gui.backgroundColor

  let gfx = gui.gfx
  gfx.beginFrame(vec2(widthPixels.float, heightPixels.float), pixelDensity)
  gfx.resetClip()

  gfx.saveState()

  gui.updateHovers()
  gui.wasHovered = gui.isHovered
  gui.isHovered = gui in gui.hovers

  gui.update(gui)
  gui.draw(gui)

  gfx.endFrame(vec2(widthPixels.float, heightPixels.float))
  gui.previousTime = gui.time
  gui.justCreated = false

proc newGui*(): Gui =
  result = Gui()
  when defined(emscripten):
    GcRef(result)
  result.justCreated = true
  result.gfx = newGfx()
  result.gui = result
  result.update = proc(widget: GuiWidget) = widget.updateChildren()
  result.draw = proc(widget: GuiWidget) = widget.drawChildren()
  result.dontClip = true