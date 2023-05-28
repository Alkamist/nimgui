{.experimental: "codeReordering".}
{.experimental: "overloadableEnums".}

# import ./gfxmod; export gfxmod
import ./math
import vectorgraphics; export vectorgraphics

const densityPixelDpi = 96.0

type
  # CursorStyle* = enum
  #   Arrow
  #   IBeam
  #   Crosshair
  #   PointingHand
  #   ResizeLeftRight
  #   ResizeTopBottom
  #   ResizeTopLeftBottomRight
  #   ResizeTopRightBottomLeft

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

  SharedState* = ref object
    pixelDensity*: float
    vg*: VectorGraphics
    hovers*: seq[Widget]
    time*: float
    timePrevious*: float
    mouseCapture* {.cursor.}: Widget
    mousePosition*: Vec2
    mousePositionPrevious*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

  Widget* = ref object of RootObj
    update*: proc(widget: Widget)
    draw*: proc(widget: Widget)
    sharedState*: SharedState
    parent* {.cursor.}: Widget
    children*: seq[Widget]
    position*: Vec2
    size*: Vec2
    dontDraw*: bool
    clipDrawing*: bool
    clipInput*: bool
    consumeInput*: bool

# =================================================================================
# Shared state
# =================================================================================

proc new*(_: typedesc[SharedState]): SharedState =
  result = SharedState()
  result.hovers = newSeqOfCap[Widget](16)
  result.mousePresses = newSeqOfCap[MouseButton](16)
  result.mouseReleases = newSeqOfCap[MouseButton](16)
  result.keyPresses = newSeqOfCap[KeyboardKey](16)
  result.keyReleases = newSeqOfCap[KeyboardKey](16)
  result.textInput = newStringOfCap(16)
  result.vg = VectorGraphics.new()

proc update*(state: SharedState) =
  state.hovers.setLen(0)
  state.mousePresses.setLen(0)
  state.mouseReleases.setLen(0)
  state.keyPresses.setLen(0)
  state.keyReleases.setLen(0)
  state.textInput.setLen(0)
  state.mousePositionPrevious = state.mousePosition
  state.timePrevious = state.time

# =================================================================================
# Root
# =================================================================================

proc newRoot*(_: typedesc[Widget]): Widget =
  result = Widget()

  result.dontDraw = false
  result.consumeInput = false
  result.clipInput = false
  result.clipDrawing = false

  result.sharedState = SharedState.new()

  result.update = proc(widget: Widget) = widget.updateChildren()
  result.draw = proc(widget: Widget) = widget.drawChildren()

proc processFrame*(widget: Widget, time: float) =
  let vg = widget.sharedState.vg

  widget.updateHovers()
  vg.beginFrame(int(widget.size.x), int(widget.size.y), 1.0)

  widget.updateWidget()
  widget.drawWidget()

  vg.endFrame()
  widget.sharedState.update()

proc inputResize*(widget: Widget, width, height: float) =
  widget.size = vec2(width, height)

proc inputMouseMove*(widget: Widget, x, y: float) =
  widget.sharedState.mousePosition = vec2(x, y)

proc inputMousePress*(widget: Widget, button: MouseButton, x, y: float) =
  widget.sharedState.mousePosition = vec2(x, y)
  widget.sharedState.mousePresses.add(button)

proc inputMouseRelease*(widget: Widget, button: MouseButton, x, y: float) =
  widget.sharedState.mousePosition = vec2(x, y)
  widget.sharedState.mouseReleases.add(button)

proc inputMouseWheel*(widget: Widget, x, y: float) =
  widget.sharedState.mouseWheel = vec2(x, y)

proc inputKeyPress*(widget: Widget, key: KeyboardKey) =
  widget.sharedState.keyPresses.add(key)

proc inputKeyRelease*(widget: Widget, key: KeyboardKey) =
  widget.sharedState.keyReleases.add(key)

proc inputText*(widget: Widget, text: string) =
  widget.sharedState.textInput &= text

proc inputDpi*(widget: Widget, dpi: float) =
  widget.sharedState.pixelDensity = dpi / densityPixelDpi

proc updateHovers(widget: Widget) =
  if not widget.isRoot:
    return

  let state = widget.sharedState
  state.hovers.setLen(0)

  let childHitTest = widget.childMouseHitTest()

  for i in countdown(childHitTest.len - 1, 0, 1):
    let hit = childHitTest[i]
    state.hovers.add(hit)
    if hit.consumeInput:
      return

    if widget.bounds.contains(state.mousePosition) and state.mouseCapture == nil:
      state.hovers.add(widget)

    if state.mouseCapture != nil:
      state.hovers.add(state.mouseCapture)

# =================================================================================
# Widget
# =================================================================================

template updateHook*(widgetToHook: Widget, code: untyped): untyped =
  let previousUpdate = widgetToHook.update
  widgetToHook.update = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(widgetToHook)(widgetBase)
    let vg {.inject.} = self.vg
    previousUpdate(widgetBase)
    code

template drawHook*(widgetToHook: Widget, code: untyped): untyped =
  let previousDraw = widgetToHook.draw
  widgetToHook.draw = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(widgetToHook)(widgetBase)
    let vg {.inject.} = self.vg
    previousDraw(widgetBase)
    code

proc isRoot*(widget: Widget): bool =
  return widget.parent == nil

template x*(widget: Widget): untyped = widget.position.x
template `x=`*(widget: Widget, value: untyped): untyped = widget.position.x = value
template y*(widget: Widget): untyped = widget.position.y
template `y=`*(widget: Widget, value: untyped): untyped = widget.position.y = value
template width*(widget: Widget): untyped = widget.size.x
template `width=`*(widget: Widget, value: untyped): untyped = widget.size.x = value
template height*(widget: Widget): untyped = widget.size.y
template `height=`*(widget: Widget, value: untyped): untyped = widget.size.y = value

proc bounds*(widget: Widget): Rect2 =
  return rect2(widget.position, widget.size)

proc globalPosition*(widget: Widget): Vec2 =
  if widget.isRoot:
    return widget.position
  else:
    return widget.position + widget.parent.globalPosition

proc globalMousePosition*(widget: Widget): Vec2 =
  return widget.sharedState.mousePosition

proc mousePosition*(widget: Widget): Vec2 =
  return widget.sharedState.mousePosition - widget.globalPosition

proc mouseDelta*(widget: Widget): Vec2 =
  let state = widget.sharedState
  return state.mousePosition - state.mousePositionPrevious

proc deltaTime*(widget: Widget): float =
  let state = widget.sharedState
  return state.time - state.timePrevious

proc mouseDown*(widget: Widget, button: MouseButton): bool =
  let state = widget.sharedState
  return state.mouseDownStates[button]

proc keyDown*(widget: Widget, key: KeyboardKey): bool =
  let state = widget.sharedState
  return state.keyDownStates[key]

proc mouseMoved*(widget: Widget): bool =
  return widget.mouseDelta != vec2(0, 0)

proc mouseWheelMoved*(widget: Widget): bool =
  let state = widget.sharedState
  return state.mouseWheel != vec2(0, 0)

proc mousePressed*(widget: Widget, button: MouseButton): bool =
  let state = widget.sharedState
  return button in state.mousePresses

proc mouseReleased*(widget: Widget, button: MouseButton): bool =
  let state = widget.sharedState
  return button in state.mouseReleases

proc anyMousePressed*(widget: Widget): bool =
  let state = widget.sharedState
  return state.mousePresses.len > 0

proc anyMouseReleased*(widget: Widget): bool =
  let state = widget.sharedState
  return state.mouseReleases.len > 0

proc keyPressed*(widget: Widget, key: KeyboardKey): bool =
  let state = widget.sharedState
  return key in state.keyPresses

proc keyReleased*(widget: Widget, key: KeyboardKey): bool =
  let state = widget.sharedState
  return key in state.keyReleases

proc anyKeyPressed*(widget: Widget): bool =
  let state = widget.sharedState
  return state.keyPresses.len > 0

proc anyKeyReleased*(widget: Widget): bool =
  let state = widget.sharedState
  return state.keyReleases.len > 0

proc isHovered*(widget: Widget): bool =
  let state = widget.sharedState
  return widget in state.hovers

proc isHoveredIncludingChildren*(widget: Widget): bool =
  if widget.isHovered:
    return true
  for child in widget.children:
    if child.isHoveredIncludingChildren:
      return true

proc captureMouse*(widget: Widget) =
  widget.sharedState.mouseCapture = widget

proc releaseMouseCapture*(widget: Widget) =
  widget.sharedState.mouseCapture = nil

proc vg*(widget: Widget): VectorGraphics =
  return widget.sharedState.vg

proc addWidget*(parent: Widget, T: typedesc = Widget): T =
  result = T()

  result.dontDraw = false
  result.consumeInput = true
  result.clipInput = true
  result.clipDrawing = true

  result.sharedState = parent.sharedState
  result.parent = parent
  result.update = proc(widget: Widget) = widget.updateChildren()
  result.draw = proc(widget: Widget) = widget.drawChildren()

  parent.children.add(result)

proc updateChildren*(widget: Widget) =
  let vg = widget.vg
  for child in widget.children:
    vg.saveState()
    vg.translate(child.position)
    if child.clipDrawing:
      vg.clip(vec2(0, 0), child.size)
    child.updateWidget()
    vg.restoreState()

proc drawChildren*(widget: Widget) =
  let vg = widget.vg
  for child in widget.children:
    vg.saveState()
    vg.translate(child.position)
    if child.clipDrawing:
      vg.clip(vec2(0, 0), child.size)
    child.drawWidget()
    vg.restoreState()

proc bringToTop*(widget: Widget) =
  let parent = widget.parent

  # Already on top.
  if parent.children[parent.children.len - 1] == widget:
    return

  var foundChild = false

  # Go through all the children to find the widget.
  for i in 0 ..< parent.children.len - 1:
    if not foundChild and parent.children[i] == widget:
      foundChild = true

    # When found, shift all widgets afterward one index lower.
    if foundChild:
      parent.children[i] = parent.children[i + 1]

  # Put the widget at the end.
  if foundChild:
    parent.children[parent.children.len - 1] = widget

proc updateWidget(widget: Widget) =
  if widget.update != nil:
    widget.update(widget)

proc drawWidget(widget: Widget) =
  if widget.dontDraw:
    return
  if widget.draw != nil:
    widget.draw(widget)

proc childMouseHitTest(widget: Widget): seq[Widget] =
  let mouseCapture = widget.sharedState.mouseCapture
  for child in widget.children:
    let mouseInside = child.bounds.contains(widget.mousePosition) or not child.clipInput
    let noCapture = mouseCapture == nil
    let captureIsChild = mouseCapture != nil and mouseCapture == child
    if (noCapture and mouse_inside) or (captureIsChild and mouse_inside):
      result.add(child)
      let hitTest = child.childMouseHitTest()
      for hit in hitTest:
        result.add(hit)