import std/math
import std/tables
import std/algorithm
import oswindow; export oswindow
import ./vectorgraphics; export vectorgraphics

type
  GuiNode* = ref object of RootObj
    root* {.cursor.}: GuiRoot
    parent* {.cursor.}: GuiNode
    name*: string
    init*: bool
    zIndex*: int
    highestZIndex*: int
    position*: Vec2
    children*: Table[string, GuiNode]
    activeChildren*: seq[GuiNode]
    drawCommands*: seq[DrawCommand]
    requestedHover*: bool
    endUpdateProc*: proc(node: GuiNode)
    childIsHovered*: bool

  GuiRoot* = ref object of GuiNode
    size*: Vec2
    scale*: float
    time*: float
    cursorStyle*: CursorStyle
    hover*: GuiNode

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
    previousTime*: float
    previousGlobalMousePosition*: Vec2

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

proc globalPosition*(node: GuiNode): Vec2 =
  if node.parent != nil:
    node.parent.globalPosition + node.position
  else:
    node.position

proc mousePosition*(node: GuiNode): Vec2 =
  node.globalMousePosition - node.globalPosition

proc cursorStyle*(node: GuiNode): CursorStyle =
  node.root.cursorStyle

proc `cursorStyle=`*(node: GuiNode, style: CursorStyle) =
  node.root.cursorStyle = style

proc isHovered*(node: GuiNode): bool =
  node.root.hover == node

proc requestHover*(node: GuiNode) =
  node.requestedHover = true

proc clearHover*(node: GuiNode) =
  if node.root.hover == node:
    node.root.hover = nil

proc getNode*(node: GuiNode, name: string, T: typedesc): T =
  if node.children.hasKey(name):
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    result = T(node.children[name])
    result.init = false
  else:
    result = T()
    result.root = node.root
    result.parent = node
    result.init = true
    result.name = name
    node.children[name] = result

proc getNode*(node: GuiNode, name: string): GuiNode =
  node.getNode(name, GuiNode)

proc fullName*(node: GuiNode): string =
  if node.parent == nil:
    node.name
  else:
    node.parent.fullName & "." & node.name

proc pixelAlign*(node: GuiNode, value: float): float =
  let scale = node.root.scale
  round(value * scale) / scale

proc pixelAlign*(node: GuiNode, value: Vec2): Vec2 =
  vec2(node.pixelAlign(value.x), node.pixelAlign(value.y))

proc register*(node: GuiNode) =
  if node.parent != nil:
    node.parent.activeChildren.add(node)

proc bringToFront*(node: GuiNode) =
  if node.parent == nil: return
  node.zIndex = node.parent.highestZIndex + 1
  node.parent.bringToFront()

template endUpdate*(node: GuiNode, code) =
  node.endUpdateProc = proc(nodeBase: GuiNode) =
    let `node` {.inject.} = typeof(node)(nodeBase)
    code

proc flattenDrawOrder(node: GuiNode) =
  if node.endUpdateProc != nil:
    node.endUpdateProc(node)

  node.root.drawOrder.add(node)

  node.activeChildren.sort(proc(x, y: GuiNode): int =
    cmp(x.zIndex, y.zIndex)
  )

  for child in node.activeChildren:
    child.flattenDrawOrder()

  if node.activeChildren.len > 0:
    node.highestZIndex = node.activeChildren[^1].zIndex

  node.activeChildren.setLen(0)

proc updateChildIsHoveredForParents(node: GuiNode) =
  if node.parent != nil:
    node.parent.childIsHovered = true
    node.parent.updateChildIsHoveredForParents()

proc new*(_: typedesc[GuiRoot]): GuiRoot =
  result = GuiRoot()
  result.root = result
  result.name = "root"
  result.init = true
  result.vgCtx = VectorGraphicsContext.new()

proc beginFrame*(root: GuiRoot) =
  root.vgCtx.beginFrame(root.size, root.scale)
  root.cursorStyle = Arrow

proc endFrame*(root: GuiRoot) =
  root.flattenDrawOrder()

  let vgCtx = root.vgCtx

  root.hover = nil

  for node in root.drawOrder:
    vgCtx.renderDrawCommands(node.drawCommands)
    node.drawCommands.setLen(0)
    if node.requestedHover:
      root.hover = node
      node.requestedHover = false
    node.childIsHovered = false

  if root.hover != nil:
    root.hover.updateChildIsHoveredForParents()

  root.drawOrder.setLen(0)
  root.mousePresses.setLen(0)
  root.mouseReleases.setLen(0)
  root.keyPresses.setLen(0)
  root.keyReleases.setLen(0)
  root.textInput.setLen(0)
  root.mouseWheel = vec2(0, 0)
  root.previousGlobalMousePosition = root.globalMousePosition
  root.previousTime = root.time

  vgCtx.endFrame()


# ======================================================================
# Vector graphics
# ======================================================================


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
    position: position,
    text: text,
    color: color,
  )))

proc measureText*(node: GuiNode, position: Vec2, text: openArray[char]): seq[TextMeasurement] =
  node.root.vgCtx.measureText(position, text)

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