{.experimental: "codeReordering".}
{.experimental: "overloadableEnums".}

import std/tables
import std/algorithm
import ./math; export math
import oswindow; export oswindow
import vectorgraphics; export vectorgraphics

type
  GuiAnchorX* = enum
    Left
    Center
    Right

  GuiAnchorY* = enum
    Top
    Center
    Bottom

  GuiAnchor* = object
    x*: GuiAnchorX
    y*: GuiAnchorY

  GuiLayout* = object
    anchor*: GuiAnchor
    position*: Vec2
    size*: Vec2

  GuiNode* = ref object of RootObj
    root* {.cursor.}: GuiRoot
    parent* {.cursor.}: GuiNode
    children*: Table[string, GuiNode]
    activeChildren*: seq[GuiNode]

    id*: string
    zIndex*: int
    passInput*: bool
    position*: Vec2
    size*: Vec2
    anchor*: GuiAnchor
    drawProc*: proc(node: GuiNode)
    cursorStyle*: CursorStyle

    init*: bool
    isHovered*: bool
    isHoveredIncludingChildren*: bool
    firstAccessThisFrame*: bool

    childLayoutQueue*: seq[GuiLayout]

  GuiRoot* = ref object of GuiNode
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


proc isRoot*(node: GuiNode): bool = node.parent == nil

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

proc topLeftPosition*(node: GuiNode): Vec2 =
  let anchor = node.anchor
  let left = case anchor.x:
    of Left: node.x
    of Center: node.x - node.width * 0.5
    of Right: node.x - node.width
  let top = case anchor.y:
    of Top: node.y
    of Center: node.y - node.height * 0.5
    of Bottom: node.y - node.height
  vec2(left, top)

proc globalMousePosition*(node: GuiNode): Vec2 = node.root.globalMousePosition

proc globalTopLeftPosition*(node: GuiNode): Vec2 =
  let parent = node.parent
  if parent == nil:
    node.position
  else:
    parent.globalTopLeftPosition + node.topLeftPosition

proc mousePosition*(node: GuiNode): Vec2 = node.globalMousePosition - node.globalTopLeftPosition
proc captureMouse*(node: GuiNode) = node.root.mouseCapture = node
proc releaseMouse*(node: GuiNode) = node.root.mouseCapture = nil

proc lastChild*(node: GuiNode): GuiNode =
  if node.activeChildren.len > 0:
    return node.activeChildren[^1]

proc mouseIsInside*(node: GuiNode): bool =
  let m = node.mousePosition
  let size = node.size
  m.x >= 0 and m.x <= size.x and
  m.y >= 0 and m.y <= size.y

proc bringToTop*(node: GuiNode) =
  let parent = node.parent
  if parent == nil:
    return

  var topZIndex = low(int)
  for id, child in parent.children:
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
  vg.translate(node.globalTopLeftPosition.pixelAlign(scale))
  if node.drawProc != nil:
    node.drawProc(node)
  vg.restoreState()

  for child in node.activeChildren:
    child.drawNode()

  # Set the size back to normal.
  node.size = size
  node.drawProc = nil
  node.activeChildren.setLen(0)
  node.childLayoutQueue.setLen(0)
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

proc applyLayout(parent, child: GuiNode) =
  if parent.childLayoutQueue.len > 0:
    let layout = parent.childLayoutQueue.pop()
    child.anchor = layout.anchor
    child.position = layout.position
    child.size = layout.size

proc addNode*(parent: GuiNode, id: string, T: typedesc = GuiNode): T {.discardable.} =
  if parent.children.hasKey(id):
    {.hint[ConvFromXtoItselfNotNeeded]: off.}
    result = T(parent.children[id])
    result.init = false
  else:
    result = T()
    result.root = parent.root
    result.parent = parent
    result.id = id
    result.init = true
    result.firstAccessThisFrame = true
    parent.children[id] = result

  if result.firstAccessThisFrame:
    parent.activeChildren.add(result)
    parent.applyLayout(result)
    result.firstAccessThisFrame = false

proc sortActiveNodesByZIndex(node: GuiNode) =
  node.activeChildren.sort do (x, y: GuiNode) -> int:
    cmp(x.zIndex, y.zIndex)

proc updateMouseCaptureHovers(capture: GuiNode) =
  if capture.parent != nil:
    capture.parent.isHoveredIncludingChildren = true
    capture.parent.updateMouseCaptureHovers()

proc clearHovers(node: GuiNode) =
  node.isHovered = false
  node.isHoveredIncludingChildren = false
  for child in node.activeChildren:
    child.isHovered = false
    child.clearHovers()

proc updateHovers(node: GuiNode) =
  let root = node.root
  let mouseCapture = root.mouseCapture
  if mouseCapture != nil:
    node.clearHovers()
    mouseCapture.isHovered = true
    mouseCapture.isHoveredIncludingChildren = true
    root.mouseCapture.updateMouseCaptureHovers()

  else:
    var inputConsumed = false
    for child in node.activeChildren.reversed():
      child.isHovered =
        (not inputConsumed) and
        node.isHoveredIncludingChildren and
        child.mouseIsInside

      child.isHoveredIncludingChildren = node.isHovered

      if child.isHovered and not child.passInput:
        inputConsumed = true
        node.isHovered = false

      child.updateHovers()


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
# Layout
# =================================================================================


proc anchor*(x: GuiAnchorX, y: GuiAnchorY): GuiAnchor =
  GuiAnchor(x: x, y: y)

proc queueLayout*(node: GuiNode, layout: GuiLayout) =
  node.childLayoutQueue.insert(layout, 0)

proc queueGrid*(node: GuiNode, columns, rows: int, spacing, padding = vec2(0, 0)) =
  if columns < 1 or rows < 1:
    return

  # Seems way more complicated than it should be
  # but it seems to work. I don't know what I'm doing.
  let n = vec2(float(columns), float(rows))
  let spacings = spacing * (n - 1.0)
  let gridPosition = padding
  let gridSize = node.size - padding * 2.0
  let childSize = (gridSize - spacings) / n
  let cellSize = gridSize / n
  for row in 0 ..< rows:
    for column in 0 ..< columns:
      let anchor = anchor(Left, Top)
      let iteration = vec2(float(column), float(row))
      let multiplier = iteration / vec2(float(columns), float(rows))
      let position = gridPosition + iteration * cellSize + multiplier * spacing
      let size = childSize
      node.queueLayout(GuiLayout(
        anchor: anchor,
        position: position,
        size: size,
      ))

# proc queueAbove*(node: GuiNode, distance: float) =
#   let lastChild = node.lastChild
#   if lastChild != nil:
#     let y = lastChild.topLeftPosition.y
#     node.queueLayout(GuiLayout(
#       anchor: (none GuiAnchorX, some GuiAnchorY.Bottom),
#       position: (none float, some y - distance),
#       size: (none float, none float)
#     ))

# proc queueBelow*(node: GuiNode, distance: float) =
#   let lastChild = node.lastChild
#   if lastChild != nil:
#     let y = lastChild.topLeftPosition.y
#     let height = lastChild.height
#     node.queueLayout(GuiLayout(
#       anchor: (none GuiAnchorX, some GuiAnchorY.Top),
#       position: (none float, some y + height + distance),
#       size: (none float, none float)
#     ))



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