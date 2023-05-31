{.experimental: "codeReordering".}
{.experimental: "overloadableEnums".}

import ./math; export math
import vectorgraphics; export vectorgraphics

type
  CursorStyle* = enum
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

  SharedState* = ref object
    userData*: pointer
    contentScale*: float
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
    activeCursorStyle*: CursorStyle
    activeCursorStylePrevious*: CursorStyle

  Widget* = ref object of RootObj
    updateProc*: proc(widget: Widget)
    drawProc*: proc(widget: Widget)
    sharedState*: SharedState
    parent* {.cursor.}: Widget
    children*: seq[Widget]
    position*: Vec2
    size*: Vec2
    dontDraw*: bool
    clipDrawing*: bool
    clipInput*: bool
    consumeInput*: bool
    cursorStyle*: CursorStyle

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
  state.mouseWheel = vec2(0, 0)
  state.mousePositionPrevious = state.mousePosition
  state.timePrevious = state.time
  state.activeCursorStylePrevious = state.activeCursorStyle

proc cursorStyleChanged*(state: SharedState): bool =
  state.activeCursorStyle != state.activeCursorStylePrevious

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

  result.updateProc = proc(widget: Widget) = widget.updateChildren()
  result.drawProc = proc(widget: Widget) = widget.drawChildren()

proc processFrame*(widget: Widget, time: float) =
  let vg = widget.sharedState.vg

  widget.updateHovers()

  vg.beginFrame(int(widget.size.x), int(widget.size.y), widget.sharedState.contentScale)
  widget.updateWidget()
  vg.endFrame()

  vg.beginFrame(int(widget.size.x), int(widget.size.y), widget.sharedState.contentScale)
  widget.drawWidget()
  vg.endFrame()

  let activeCursorStyle =
    if widget.sharedState.hovers.len > 0:
      widget.sharedState.hovers[^1].cursorStyle
    else:
      CursorStyle.Arrow

  widget.sharedState.update()

  widget.sharedState.activeCursorStyle = activeCursorStyle

proc activeCursorStyle*(widget: Widget): CursorStyle =
  widget.sharedState.activeCursorStyle

proc inputResize*(widget: Widget, width, height: float) =
  widget.size = vec2(width, height)

proc inputMouseMove*(widget: Widget, x, y: float) =
  widget.sharedState.mousePosition = vec2(x, y) / widget.sharedState.contentScale

proc inputMousePress*(widget: Widget, button: MouseButton, x, y: float) =
  widget.sharedState.mousePosition = vec2(x, y) / widget.sharedState.contentScale
  widget.sharedState.mousePresses.add(button)

proc inputMouseRelease*(widget: Widget, button: MouseButton, x, y: float) =
  widget.sharedState.mousePosition = vec2(x, y) / widget.sharedState.contentScale
  widget.sharedState.mouseReleases.add(button)

proc inputMouseWheel*(widget: Widget, x, y: float) =
  widget.sharedState.mouseWheel = vec2(x, y)

proc inputKeyPress*(widget: Widget, key: KeyboardKey) =
  widget.sharedState.keyPresses.add(key)

proc inputKeyRelease*(widget: Widget, key: KeyboardKey) =
  widget.sharedState.keyReleases.add(key)

proc inputText*(widget: Widget, text: string) =
  widget.sharedState.textInput &= text

proc inputContentScale*(widget: Widget, scale: float) =
  widget.sharedState.mousePosition *= widget.sharedState.contentScale / scale
  widget.sharedState.contentScale = scale

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
  let previousUpdateProc = widgetToHook.updateProc
  widgetToHook.updateProc = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(widgetToHook)(widgetBase)
    let vg {.inject.} = self.vg
    previousUpdateProc(widgetBase)
    code

template drawHook*(widgetToHook: Widget, code: untyped): untyped =
  let previousDrawProc = widgetToHook.drawProc
  widgetToHook.drawProc = proc(widgetBase: Widget) =
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    {.hint[XDeclaredButNotUsed]: off.}
    let self {.inject.} = typeof(widgetToHook)(widgetBase)
    let vg {.inject.} = self.vg
    previousDrawProc(widgetBase)
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

proc mouseWheel*(widget: Widget): Vec2 =
  let state = widget.sharedState
  return state.mouseWheel

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

proc releaseMouse*(widget: Widget) =
  widget.sharedState.mouseCapture = nil

proc vg*(widget: Widget): VectorGraphics =
  return widget.sharedState.vg

proc pixelAlign*(widget: Widget, value: float): float =
  let contentScale = widget.sharedState.contentScale
  (value * contentScale).round / contentScale

proc pixelAlign*(widget: Widget, position: Vec2): Vec2 =
  vec2(
    widget.pixelAlign(position.x),
    widget.pixelAlign(position.y),
  )

proc addWidget*(parent: Widget, T: typedesc = Widget): T =
  mixin update, draw

  template isBaseWidget(T: typedesc): bool =
    compiles((var a: T = Widget()))

  result = T()

  result.dontDraw = false
  result.consumeInput = true
  result.clipInput = true
  result.clipDrawing = true

  result.sharedState = parent.sharedState
  result.parent = parent

  when T.isBaseWidget:
    result.updateProc = proc(widget: Widget) =
      widget.updateChildren()
    result.drawProc = proc(widget: Widget) =
      widget.drawChildren()
  else:
    result.updateProc = proc(widget: Widget) =
      T(widget).update()
    result.drawProc = proc(widget: Widget) =
      T(widget).draw()

  parent.children.add(result)

proc updateChildren*(widget: Widget) =
  let vg = widget.vg
  for child in widget.children:
    vg.saveState()
    vg.translate(child.pixelAlign(child.position))
    if child.clipDrawing:
      vg.clip(vec2(0, 0), child.size)
    child.updateWidget()
    vg.restoreState()

proc drawChildren*(widget: Widget) =
  let vg = widget.vg
  for child in widget.children:
    vg.saveState()
    vg.translate(child.pixelAlign(child.position))
    if child.clipDrawing:
      vg.clip(vec2(0, 0), child.size)
    child.drawWidget()
    vg.restoreState()

proc bringToTop*(widget: Widget) =
  let parent = widget.parent
  if parent == nil or parent.children.len == 0:
    return

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
  if widget.updateProc != nil:
    widget.updateProc(widget)

proc drawWidget(widget: Widget) =
  if widget.dontDraw:
    return
  if widget.drawProc != nil:
    widget.drawProc(widget)

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