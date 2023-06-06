{.experimental: "codeReordering".}
{.experimental: "overloadableEnums".}

import std/tables
import std/algorithm
import ./math; export math
import oswindow; export oswindow
import vectorgraphics; export vectorgraphics

type
  GuiNode* = ref object of RootObj
    root* {.cursor.}: GuiRoot
    container* {.cursor.}: GuiContainer

    id*: string
    zIndex*: int
    passInput*: bool
    position*: Vec2
    size*: Vec2
    drawProc*: proc(node: GuiNode)
    cursorStyle*: CursorStyle

    init*: bool
    isHovered*: bool
    firstAccessThisFrame*: bool

  GuiContainer* = ref object of GuiNode
    nodes*: Table[string, GuiNode]
    activeNodes*: seq[GuiNode]
    isHoveredIncludingChildren*: bool

  GuiRoot* = ref object of GuiContainer
    osWindow*: OsWindow
    vg*: VectorGraphics
    mouseCapture*: GuiNode
    contentScale*: float
    time*: float
    timePrevious*: float
    globalMousePosition*: Vec2
    globalMousePositionPrevious*: Vec2
    mouseWheel*: Vec2
    mousePresses*: seq[MouseButton]
    mouseReleases*: seq[MouseButton]
    mouseDownStates*: array[MouseButton, bool]
    keyPresses*: seq[KeyboardKey]
    keyReleases*: seq[KeyboardKey]
    keyDownStates*: array[KeyboardKey, bool]
    textInput*: string
    onFrameProc*: proc(root: GuiRoot)
    activeCursorStyle: CursorStyle


# =================================================================================
# GuiNode
# =================================================================================


proc isRoot*(node: GuiNode): bool = node.container == nil

template x*(node: GuiNode): untyped = node.position.x
template `x=`*(node: GuiNode, value: untyped): untyped = node.position.x = value
template y*(node: GuiNode): untyped = node.position.y
template `y=`*(node: GuiNode, value: untyped): untyped = node.position.y = value
template width*(node: GuiNode): untyped = node.size.x
template `width=`*(node: GuiNode, value: untyped): untyped = node.size.x = value
template height*(node: GuiNode): untyped = node.size.y
template `height=`*(node: GuiNode, value: untyped): untyped = node.size.y = value

proc vg*(node: GuiNode): VectorGraphics = node.root.vg
proc mouseDelta*(node: GuiNode): Vec2 = node.root.mouseDelta
proc time*(node: GuiNode): float = node.root.time
proc deltaTime*(node: GuiNode): float = node.root.deltaTime
proc mouseDown*(node: GuiNode, button: MouseButton): bool = node.root.mouseDown(button)
proc keyDown*(node: GuiNode, key: KeyboardKey): bool = node.root.keyDown(key)
proc mouseMoved*(node: GuiNode): bool = node.root.mouseMoved
proc mouseWheelMoved*(node: GuiNode): bool = node.root.mouseWheelMoved
proc mousePressed*(node: GuiNode, button: MouseButton): bool = node.root.mousePressed(button)
proc mouseReleased*(node: GuiNode, button: MouseButton): bool = node.root.mouseReleased(button)
proc anyMousePressed*(node: GuiNode): bool = node.root.anyMousePressed
proc anyMouseReleased*(node: GuiNode): bool = node.root.anyMouseReleased
proc keyPressed*(node: GuiNode, key: KeyboardKey): bool = node.root.keyPressed(key)
proc keyReleased*(node: GuiNode, key: KeyboardKey): bool = node.root.keyReleased(key)
proc anyKeyPressed*(node: GuiNode): bool = node.root.anyKeyPressed
proc anyKeyReleased*(node: GuiNode): bool = node.root.anyKeyReleased

proc globalMousePosition*(node: GuiNode): Vec2 = node.root.globalMousePosition

proc globalPosition*(node: GuiNode): Vec2 =
  let container = node.container
  if container == nil:
    node.position
  else:
    container.globalPosition + node.position

proc mousePosition*(node: GuiNode): Vec2 = node.globalMousePosition - node.globalPosition
proc captureMouse*(node: GuiNode) = node.root.mouseCapture = node
proc releaseMouse*(node: GuiNode) = node.root.mouseCapture = nil

proc mouseIsInside*(node: GuiNode): bool =
  rect2(vec2(0, 0), node.size).contains(node.mousePosition)

# proc grid*(node: GuiNode, columns, rows: int, spacing, padding = vec2(0, 0)) =
#   let n = vec2(float(columns), float(rows))
#   let spacings = spacing * (n - 1.0)
#   let gridPosition = padding
#   let gridSize = node.size - padding * 2.0
#   let childSize = (gridSize - spacings) / n
#   let cellSize = gridSize / n

#   for row in 0 ..< rows:
#     for column in 0 ..< columns:
#       let i = row * columns + column
#       if i >= node.activeNodes.len:
#         return

#       let child = node.activeNodes[i]
#       child.size = childSize
#       child.position = gridPosition + vec2(float(column), float(row)) * cellSize

proc bringToTop*(node: GuiNode) =
  let container = node.container
  if container == nil:
    return

  var topZIndex = low(int)
  for id, child in container.nodes:
    if child.zIndex >= topZIndex:
      topZIndex = child.zIndex

  node.zIndex = topZIndex + 1

proc pixelAlign(value, contentScale: float): float =
  round(value * contentScale) / contentScale

proc pixelAlign(position: Vec2, contentScale: float): Vec2 =
  vec2(
    position.x.pixelAlign(contentScale),
    position.y.pixelAlign(contentScale),
  )

proc drawNode(node: GuiNode) =
  let vg = node.vg

  if node.isHovered and not node.passInput:
    node.root.activeCursorStyle = node.cursorStyle

  let scale = node.root.contentScale

  # Pixel align the node's size for the draw call so it is crisp.
  let size = node.size
  node.size = size.pixelAlign(scale)

  vg.saveState()
  vg.translate(node.globalPosition.pixelAlign(scale))
  if node.drawProc != nil:
    node.drawProc(node)
  vg.restoreState()

  if node of GuiContainer:
    let container = GuiContainer(node)
    for child in container.activeNodes:
      child.drawNode()
    container.activeNodes.setLen(0)

  # Set the size back to normal.
  node.size = size
  node.drawProc = nil
  node.firstAccessThisFrame = true

template draw*(node: GuiNode, code: untyped): untyped =
  if true:
    node.drawProc = proc(widgetBase: GuiNode) =
      {.hint[XDeclaredButNotUsed]: off.}
      {.hint[ConvFromXtoItselfNotNeeded]: off.}
      let `node` {.inject.} = typeof(node)(widgetBase)
      code

template drawHook*(node: GuiNode, code: untyped): untyped =
  if true:
    let previousDrawProc = node.drawProc
    node.drawProc = proc(widgetBase: GuiNode) =
      {.hint[XDeclaredButNotUsed]: off.}
      {.hint[ConvFromXtoItselfNotNeeded]: off.}
      let `node` {.inject.} = typeof(node)(widgetBase)
      if previousDrawProc != nil:
        previousDrawProc(widgetBase)
      code


# =================================================================================
# GuiContainer
# =================================================================================


proc addNode*(container: GuiContainer, id: string, T: typedesc = GuiNode): T {.discardable.} =
  if container.nodes.hasKey(id):
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    result = T(container.nodes[id])
    result.init = false
  else:
    result = T()
    result.root = container.root
    result.container = container
    result.id = id
    result.init = true
    result.firstAccessThisFrame = true
    container.nodes[id] = result

  if result.firstAccessThisFrame:
    container.activeNodes.add(result)
    result.firstAccessThisFrame = false

proc sortActiveNodesByZIndex(container: GuiContainer) =
  container.activeNodes.sort do (x, y: GuiNode) -> int:
    cmp(x.zIndex, y.zIndex)

proc updateMouseCaptureHovers(capture: GuiNode) =
  if capture.container != nil:
    capture.container.isHoveredIncludingChildren = true
    capture.container.updateMouseCaptureHovers()

proc clearHovers(container: GuiContainer) =
  container.isHovered = false
  container.isHoveredIncludingChildren = false
  for node in container.activeNodes:
    node.isHovered = false
    if node of GuiContainer:
      GuiContainer(node).clearHovers()

proc updateHovers(container: GuiContainer) =
  let root = container.root
  let mouseCapture = root.mouseCapture
  if mouseCapture != nil:
    container.clearHovers()
    mouseCapture.isHovered = true
    if mouseCapture of GuiContainer:
      GuiContainer(mouseCapture).isHoveredIncludingChildren = true
    root.mouseCapture.updateMouseCaptureHovers()

  else:
    var inputConsumed = false
    for node in container.activeNodes.reversed():
      node.isHovered =
        (not inputConsumed) and
        container.isHoveredIncludingChildren and
        node.mouseIsInside

      if node.isHovered and not node.passInput:
        inputConsumed = true
        container.isHovered = false

      if node of GuiContainer:
        let nodeAsContainer = GuiContainer(node)
        nodeAsContainer.isHoveredIncludingChildren = nodeAsContainer.isHovered
        nodeAsContainer.updateHovers()


# =================================================================================
# GuiRoot
# =================================================================================


proc mouseDelta*(root: GuiRoot): Vec2 = root.globalMousePosition - root.globalMousePositionPrevious
proc deltaTime*(root: GuiRoot): float = root.time - root.timePrevious
proc mouseDown*(root: GuiRoot, button: MouseButton): bool = root.mouseDownStates[button]
proc keyDown*(root: GuiRoot, key: KeyboardKey): bool = root.keyDownStates[key]
proc mouseMoved*(root: GuiRoot): bool = root.mouseDelta != vec2(0, 0)
proc mouseWheelMoved*(root: GuiRoot): bool = root.mouseWheel != vec2(0, 0)
proc mousePressed*(root: GuiRoot, button: MouseButton): bool = button in root.mousePresses
proc mouseReleased*(root: GuiRoot, button: MouseButton): bool = button in root.mouseReleases
proc anyMousePressed*(root: GuiRoot): bool = root.mousePresses.len > 0
proc anyMouseReleased*(root: GuiRoot): bool = root.mouseReleases.len > 0
proc keyPressed*(root: GuiRoot, key: KeyboardKey): bool = key in root.keyPresses
proc keyReleased*(root: GuiRoot, key: KeyboardKey): bool = key in root.keyReleases
proc anyKeyPressed*(root: GuiRoot): bool = root.keyPresses.len > 0
proc anyKeyReleased*(root: GuiRoot): bool = root.keyReleases.len > 0

proc new*(_: typedesc[GuiRoot]): GuiRoot =
  result = GuiRoot()

  result.id = "Root"
  result.root = result

  result.mousePresses = newSeqOfCap[MouseButton](16)
  result.mouseReleases = newSeqOfCap[MouseButton](16)
  result.keyPresses = newSeqOfCap[KeyboardKey](16)
  result.keyReleases = newSeqOfCap[KeyboardKey](16)
  result.textInput = newStringOfCap(16)

  result.osWindow = OsWindow.new()
  result.osWindow.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
  result.osWindow.setSize(800, 600)
  result.osWindow.show()

  result.vg = VectorGraphics.new()

  result.attachToOsWindow()

proc update(root: GuiRoot) =
  root.time = root.osWindow.time
  root.isHoveredIncludingChildren = root.osWindow.isHovered
  root.isHovered = root.isHoveredIncludingChildren

  let (pixelWidth, pixelHeight) = root.osWindow.size
  root.vg.beginFrame(pixelWidth, pixelHeight, root.contentScale)

  if root.onFrameProc != nil:
    root.onFrameProc(root)

  root.sortActiveNodesByZIndex()
  root.updateHovers()
  root.drawNode()

  root.vg.endFrame()

  if root.isHoveredIncludingChildren:
    root.osWindow.setCursorStyle(root.activeCursorStyle)

  root.mousePresses.setLen(0)
  root.mouseReleases.setLen(0)
  root.keyPresses.setLen(0)
  root.keyReleases.setLen(0)
  root.textInput.setLen(0)
  root.mouseWheel = vec2(0, 0)
  root.globalMousePositionPrevious = root.globalMousePosition
  root.timePrevious = root.time

template onFrame*(root: GuiRoot, code: untyped): untyped =
  root.onFrameProc = proc(argGui: GuiRoot) =
    {.hint[XDeclaredButNotUsed]: off.}
    let `root` {.inject.} = argGui
    code

proc run*(root: GuiRoot) =
  root.osWindow.run()


# =================================================================================
# OsWindow Binding
# =================================================================================


const densityPixelDpi = 96.0

proc toContentScale(dpi: float): float =
  dpi / densityPixelDpi

proc toDensityPixels(pixels: int, dpi: float): float =
  float(pixels) * dpi / densityPixelDpi

proc attachToOsWindow(root: GuiRoot) =
  let window = root.osWindow
  window.userData = cast[pointer](root)

  let dpi = window.dpi
  root.contentScale = dpi.toContentScale

  let (width, height) = window.size
  root.width = width.toDensityPixels(dpi)
  root.height = height.toDensityPixels(dpi)

  window.onFrame = proc(window: OsWindow) =
    let root = cast[GuiRoot](window.userData)
    root.update()
    window.swapBuffers()

  window.onResize = proc(window: OsWindow, width, height: int) =
    let root = cast[GuiRoot](window.userData)
    let dpi = window.dpi
    root.width = width.toDensityPixels(dpi)
    root.height = height.toDensityPixels(dpi)

  window.onMouseMove = proc(window: OsWindow, x, y: int) =
    let root = cast[GuiRoot](window.userData)
    let dpi = window.dpi
    root.globalMousePosition.x = x.toDensityPixels(dpi)
    root.globalMousePosition.y = y.toDensityPixels(dpi)
    window.setCursorStyle(root.activeCursorStyle)

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
    root.contentScale = dpi.toContentScale