import std/tables
import std/algorithm
import oswindow; export oswindow
import ./vectorgraphics; export vectorgraphics

type
  GuiNode* = ref object of RootObj
    root* {.cursor.}: GuiRoot
    owner* {.cursor.}: GuiNode
    parent* {.cursor.}: GuiNode
    name*: string
    position*: Vec2
    size*: Vec2
    zIndex*: int
    highestChildZIndex*: int
    init*: bool
    childIsHovered*: bool
    clipChildren*: bool
    ownedChildren*: Table[string, GuiNode]
    activeChildren*: seq[GuiNode]
    drawCommands*: seq[DrawCommand]
    requestedHover: bool
    cachedGlobalPosition: Vec2
    cachedGlobalClipRect: tuple[position, size: Vec2]

  GuiRoot* = ref object of GuiNode
    scale*: float
    time*: float
    cursorStyle*: CursorStyle
    hover*: GuiNode
    mouseOver*: GuiNode
    hoverCapture*: GuiNode

    # Input
    globalMousePosition*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string

    # Vector graphics
    vgCtx*: VectorGraphicsContext
    drawOrder: seq[GuiNode]

    # Previous frame state
    previousTime: float
    previousGlobalMousePosition: Vec2

proc globalMousePosition*(node: GuiNode): Vec2 = node.root.globalMousePosition
proc mouseDelta*(node: GuiNode): Vec2 = node.root.globalMousePosition - node.root.previousGlobalMousePosition
proc deltaTime*(node: GuiNode): float = node.root.time - node.root.previousTime
proc mouseDown*(node: GuiNode, button: MouseButton): bool = node.root.mouseDownStates[button]
proc keyDown*(node: GuiNode, key: KeyboardKey): bool = node.root.keyDownStates[key]
proc mouseMoved*(node: GuiNode): bool = node.root.mouseDelta != vec2(0, 0)
proc mouseWheelMoved*(node: GuiNode): bool = node.root.mouseWheel != vec2(0, 0)
proc mousePressed*(node: GuiNode, button: MouseButton): bool = button in node.root.mousePresses
proc mouseReleased*(node: GuiNode, button: MouseButton): bool = button in node.root.mouseReleases
proc anyMousePressed*(node: GuiNode): bool = node.root.mousePresses.len > 0
proc anyMouseReleased*(node: GuiNode): bool = node.root.mouseReleases.len > 0
proc keyPressed*(node: GuiNode, key: KeyboardKey): bool = key in node.root.keyPresses
proc keyReleased*(node: GuiNode, key: KeyboardKey): bool = key in node.root.keyReleases
proc anyKeyPressed*(node: GuiNode): bool = node.root.keyPresses.len > 0
proc anyKeyReleased*(node: GuiNode): bool = node.root.keyReleases.len > 0

proc globalOffset*(node: GuiNode): Vec2 =
  if node.parent != nil:
    node.parent.globalOffset + node.parent.position
  else:
    vec2(0, 0)

proc globalPosition*(node: GuiNode): Vec2 =
  node.globalOffset + node.position

proc mousePosition*(node: GuiNode): Vec2 =
  node.globalMousePosition - node.globalPosition

proc isHovered*(node: GuiNode): bool =
  node.root.hover == node

proc mouseOver*(node: GuiNode): bool =
  node.root.mouseOver == node

proc cursorStyle*(node: GuiNode): CursorStyle =
  node.root.cursorStyle

proc `cursorStyle=`*(node: GuiNode, style: CursorStyle) =
  node.root.cursorStyle = style

proc requestHover*(node: GuiNode) =
  node.requestedHover = true

proc captureHover*(node: GuiNode) =
  if node.root.hoverCapture == nil:
    node.root.hoverCapture = node

proc releaseHover*(node: GuiNode) =
  if node.root.hoverCapture == node:
    node.root.hoverCapture = nil

proc fullName*(node: GuiNode): string =
  if node.parent != nil:
    node.parent.fullName & "." & node.name
  else:
    node.name

proc update*(node: GuiNode) =
  node.parent.activeChildren.add(node)

proc getNode*(node: GuiNode, name: string, T: typedesc): T =
  if node.ownedChildren.hasKey(name):
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    result = T(node.ownedChildren[name])
    result.init = false
  else:
    result = T()
    result.root = node.root
    result.owner = node
    result.parent = node
    result.init = true
    result.name = name
    node.ownedChildren[name] = result

proc getNode*(node: GuiNode, name: string): GuiNode =
  node.getNode(name, GuiNode)

proc intersect(a, b: tuple[position, size: Vec2]): tuple[position, size: Vec2] =
  let x1 = max(a.position.x, b.position.x)
  let y1 = max(a.position.y, b.position.y)
  var x2 = min(a.position.x + a.size.x, b.position.x + b.size.x)
  var y2 = min(a.position.y + a.size.y, b.position.y + b.size.y)
  if x2 < x1: x2 = x1
  if y2 < y1: y2 = y1
  (vec2(x1, y1), vec2(x2 - x1, y2 - y1))

proc contains(a: tuple[position, size: Vec2], b: Vec2): bool =
  b.x >= a.position.x and b.x <= a.position.x + a.size.x and
  b.y >= a.position.y and b.y <= a.position.y + a.size.y

proc updateCachedInfo(node: GuiNode) =
  let parent = node.parent
  if parent == nil:
    node.cachedGlobalPosition = node.position
    node.cachedGlobalClipRect = (node.position, node.size)
    return

  node.cachedGlobalPosition = parent.cachedGlobalPosition + node.position

  if node.clipChildren:
    node.cachedGlobalClipRect = parent.cachedGlobalClipRect.intersect((node.cachedGlobalPosition, node.size))
  else:
    node.cachedGlobalClipRect = parent.cachedGlobalClipRect

proc mouseIsInBounds(node: GuiNode): bool =
  node.cachedGlobalClipRect.contains(node.globalMousePosition)

proc unpackDrawOrder(node: GuiNode) =
  node.root.drawOrder.add(node)
  node.activeChildren.sort(proc(x, y: GuiNode): int =
    cmp(x.zIndex, y.zIndex)
  )
  node.highestChildZIndex = low(int)
  for child in node.activeChildren:
    if child.zIndex > node.highestChildZIndex:
      node.highestChildZIndex = child.zIndex
    child.unpackDrawOrder()

proc informParentOfHoverStatus(node: GuiNode) =
  if node.parent == nil:
    return
  node.parent.childIsHovered = true
  node.parent.informParentOfHoverStatus()

proc new*(_: typedesc[GuiRoot]): GuiRoot =
  result = GuiRoot()
  result.name = "Root"
  result.root = result
  result.clipChildren = true
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(root: GuiRoot) =
  root.vgCtx.beginFrame(root.size, root.scale)
  root.cursorStyle = Arrow

proc endFrame*(root: GuiRoot) =
  root.unpackDrawOrder()

  let vgCtx = root.vgCtx
  var hover: GuiNode = nil
  var mouseOver: GuiNode = nil

  for node in root.drawOrder:
    node.updateCachedInfo()

    vgCtx.renderDrawCommands [DrawCommand(kind: Clip, clip: ClipCommand(
      position: node.cachedGlobalClipRect.position,
      size: node.cachedGlobalClipRect.size,
      intersect: false,
    ))]
    vgCtx.renderDrawCommands(node.drawCommands)

    if root.hoverCapture == node:
      hover = node

    if root.hoverCapture == nil and node.requestedHover and node.mouseIsInBounds:
      hover = node

    if node.requestedHover and node.mouseIsInBounds:
      mouseOver = node

    node.childIsHovered = false
    node.requestedHover = false
    node.drawCommands.setLen(0)
    node.activeChildren.setLen(0)

  root.hover = hover
  if root.hover != nil:
    root.hover.informParentOfHoverStatus()

  root.mouseOver = mouseOver

  root.drawOrder.setLen(0)
  root.mousePresses.setLen(0)
  root.mouseReleases.setLen(0)
  root.keyPresses.setLen(0)
  root.keyReleases.setLen(0)
  root.textInput.setLen(0)
  root.mouseWheel = vec2(0, 0)
  root.previousGlobalMousePosition = root.globalMousePosition
  root.previousTime = root.time

  root.vgCtx.endFrame()


# ======================================================================
# Vector graphics
# ======================================================================


# proc pixelAlign*(root: GuiRoot, value: float): float =
#   let scale = root.scale
#   round(value * scale) / scale

# proc pixelAlign*(root: GuiRoot, value: Vec2): Vec2 =
#   vec2(root.pixelAlign(value.x), root.pixelAlign(value.y))

proc fillPath*(node: GuiNode, path: Path, paint: Paint) =
  node.drawCommands.add(DrawCommand(kind: FillPath, fillPath: FillPathCommand(
    path: path[],
    paint: paint,
    position: node.globalPosition,
  )))

proc fillPath*(node: GuiNode, path: Path, color: Color) =
  node.fillPath(path, solidColorPaint(color))

proc strokePath*(node: GuiNode, path: Path, paint: Paint, strokeWidth = 1.0) =
  node.drawCommands.add(DrawCommand(kind: StrokePath, strokePath: StrokePathCommand(
    path: path[],
    paint: paint,
    strokeWidth: strokeWidth,
    position: node.globalPosition,
  )))

proc strokePath*(node: GuiNode, path: Path, color: Color, strokeWidth = 1.0) =
  node.strokePath(path, solidColorPaint(color), strokeWidth)

proc fillTextLine*(node: GuiNode, position: Vec2, text: string, color: Color, font: Font, fontSize = 13.0) =
  node.drawCommands.add(DrawCommand(kind: FillText, fillText: FillTextCommand(
    font: font,
    fontSize: fontSize,
    position: node.globalPosition + position,
    text: text,
    color: color,
  )))

proc measureText*(node: GuiNode, position: Vec2, text: openArray[char]): seq[TextMeasurement] =
  node.root.vgCtx.measureText(node.globalPosition + position, text)

proc addFont*(node: GuiNode, data: string): Font {.discardable.} =
  node.root.vgCtx.addFont(data)


# ======================================================================
# OsWindow binding
# ======================================================================


const densityPixelDpi = 96.0

proc toScale(dpi: float): float =
  dpi / densityPixelDpi

proc toDensityPixels(pixels: int, dpi: float): float =
  float(pixels) * dpi / densityPixelDpi

proc attachToOsWindow*(root: GuiRoot, window: OsWindow) =
  GcRef(root)
  window.userData = cast[pointer](root)

  let dpi = window.dpi
  root.scale = dpi.toScale

  let (width, height) = window.size
  root.size.x = width.toDensityPixels(dpi)
  root.size.y = height.toDensityPixels(dpi)

  window.onClose = proc(window: OsWindow) =
    let root = cast[GuiRoot](window.userData)
    GcUnref(root)

  window.onResize = proc(window: OsWindow, width, height: int) =
    let root = cast[GuiRoot](window.userData)
    let dpi = window.dpi
    root.size.x = width.toDensityPixels(dpi)
    root.size.y = height.toDensityPixels(dpi)

  window.onMouseMove = proc(window: OsWindow, x, y: int) =
    let root = cast[GuiRoot](window.userData)
    let dpi = window.dpi
    root.globalMousePosition.x = x.toDensityPixels(dpi)
    root.globalMousePosition.y = y.toDensityPixels(dpi)
    window.setCursorStyle(root.cursorStyle)

  window.onMousePress = proc(window: OsWindow, button: MouseButton, x, y: int) =
    let root = cast[GuiRoot](window.userData)
    let dpi = window.dpi
    root.mouseDownStates[button] = true
    root.mousePresses.add(button)
    root.globalMousePosition.x = x.toDensityPixels(dpi)
    root.globalMousePosition.y = y.toDensityPixels(dpi)

  window.onMouseRelease = proc(window: OsWindow, button: oswindow.MouseButton, x, y: int) =
    let root = cast[GuiRoot](window.userData)
    let dpi = window.dpi
    root.mouseDownStates[button] = false
    root.mouseReleases.add(button)
    root.globalMousePosition.x = x.toDensityPixels(dpi)
    root.globalMousePosition.y = y.toDensityPixels(dpi)

  window.onMouseWheel = proc(window: OsWindow, x, y: float) =
    let root = cast[GuiRoot](window.userData)
    root.mouseWheel.x = x
    root.mouseWheel.y = y

  window.onKeyPress = proc(window: OsWindow, key: KeyboardKey) =
    let root = cast[GuiRoot](window.userData)
    root.keyDownStates[key] = true
    root.keyPresses.add(key)

  window.onKeyRelease = proc(window: OsWindow, key: oswindow.KeyboardKey) =
    let root = cast[GuiRoot](window.userData)
    root.keyDownStates[key] = false
    root.keyReleases.add(key)

  window.onTextInput = proc(window: OsWindow, text: string) =
    let root = cast[GuiRoot](window.userData)
    root.textInput &= text

  window.onDpiChange = proc(window: OsWindow, dpi: float) =
    let root = cast[GuiRoot](window.userData)
    root.scale = dpi.toScale