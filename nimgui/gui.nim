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

  GuiPlacement* = object
    anchor*: GuiAnchor
    position*: Vec2
    size*: Vec2

  GuiNode* = ref object of RootObj
    root* {.cursor.}: GuiRoot
    parent* {.cursor.}: GuiNode
    children*: Table[string, GuiNode]
    activeChildren*: seq[GuiNode] # The children that were accessed this frame.

    id*: string
    zIndex*: int # Relative to siblings.
    drawZIndex*: int # Relative to children.
    passInput*: bool
    clipChildren*: bool
    ignoreClipping*: bool # Ignore clipping of the immediate parent.
    position*: Vec2
    size*: Vec2
    anchor*: GuiAnchor
    drawProc*: proc(node: GuiNode)
    cursorStyle*: CursorStyle

    init*: bool
    isHovered*: bool
    isHoveredIncludingChildren*: bool
    isVisible*: bool
    accessCount*: int # This is per frame, for per frame initialization.

    clipRect: Rect2 # Resolved at the end of the frame to update isHovered.

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
    drawOrder: seq[GuiNode]


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

proc firstAccessThisFrame*(node: GuiNode): bool =
  node.accessCount == 1

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

proc globalMousePosition*(node: GuiNode): Vec2 =
  node.root.globalMousePosition

proc globalTopLeftPosition*(node: GuiNode): Vec2 =
  let parent = node.parent
  if parent == nil:
    node.position
  else:
    parent.globalTopLeftPosition + node.topLeftPosition

proc mousePosition*(node: GuiNode): Vec2 =
  node.globalMousePosition - node.globalTopLeftPosition

proc captureMouse*(node: GuiNode) =
  if not node.passInput:
    node.root.mouseCapture = node

proc releaseMouse*(node: GuiNode) =
  if not node.passInput:
    node.root.mouseCapture = nil

proc previous*(node: GuiNode): GuiNode =
  if node.activeChildren.len > 1:
    return node.activeChildren[^2]

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

proc addNode*(parent: GuiNode, id: string, T: typedesc = GuiNode): T =
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
    parent.children[id] = result

  result.accessCount += 1

  if result.firstAccessThisFrame:
    parent.activeChildren.add(result)


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

proc calculateDrawOrderAndUpdateClipRects(node: GuiNode): seq[GuiNode] =
  var drawOrder = newSeq[GuiNode](node.activeChildren.len + 1)

  drawOrder[0] = node
  for i in 0 ..< node.activeChildren.len:
    drawOrder[i + 1] = node.activeChildren[i]

  drawOrder.sort do (x, y: GuiNode) -> int:
    if x == y.parent:
      cmp(x.drawZIndex, y.zIndex)
    else:
      cmp(x.zIndex, y.zIndex)

  let nodeGlobalRect = rect2(node.globalTopLeftPosition, node.size)
  let clipChildren = node.clipChildren

  for child in drawOrder:
    if child == node:
      result.add(node)
    else:
      if clipChildren and not child.ignoreClipping:
        child.clipRect = node.clipRect.intersect(nodeGlobalRect)
      else:
        child.clipRect = node.clipRect

      for unpacked in child.calculateDrawOrderAndUpdateClipRects():
        result.add(unpacked)

proc updateDrawOrderAndClipRects(root: GuiRoot) =
  root.drawOrder = root.calculateDrawOrderAndUpdateClipRects()

proc informParentsThatNodeIsHovered(node: GuiNode) =
  let parent = node.parent
  if parent != nil:
    parent.isHoveredIncludingChildren = true
    parent.informParentsThatNodeIsHovered()

proc update(root: GuiRoot) =
  let vg = root.vg

  let (pixelWidth, pixelHeight) = root.osWindow.size
  root.vg.beginFrame(pixelWidth, pixelHeight, root.contentScale)

  # Run the gui logic.
  if root.onFrameProc != nil:
    root.onFrameProc(root)

  # Recursively unpack the nodes active this frame into
  # a flat buffer that is sorted by draw order
  root.clipRect = rect2(root.position, root.size)
  root.updateDrawOrderAndClipRects()

  # Draw each node in order.
  for node in root.drawOrder:
    let scale = node.root.contentScale
    let clipRect = rect2(node.clipRect.position.pixelAlign(scale), node.clipRect.size.pixelAlign(scale))

    node.isVisible = clipRect.contains(rect2(node.globalTopLeftPosition, node.size))

    if node.isVisible:
      # Pixel align the node's size for the draw call so it is crisp.
      let size = node.size
      node.size = size.pixelAlign(scale)

      vg.clip(clipRect.position, clipRect.size.pixelAlign(scale))
      vg.translate(node.globalTopLeftPosition.pixelAlign(scale))

      if node.drawProc != nil:
        node.drawProc(node)

      vg.resetClip()
      vg.resetTransform()

      # Set the size back to normal.
      node.size = size

    # Clear this state here because it's convenient.
    node.isHoveredIncludingChildren = false

  vg.endFrame()

  # Prepare the root and other nodes for the next frame.
  root.timePrevious = root.time
  root.time = root.osWindow.time

  let mouseCapture = root.mouseCapture
  let globalMousePosition = root.globalMousePosition

  var inputConsumed = false
  for node in root.drawOrder.reversed:
    if mouseCapture == nil:
      node.isHovered =
        not inputConsumed and
        node.clipRect.contains(globalMousePosition) and
        node.mouseIsInside
    else:
      node.isHovered = node == mouseCapture

    if node.isHovered and not node.passInput:
      inputConsumed = true
      node.root.activeCursorStyle = node.cursorStyle

    if node.isHovered:
      node.isHoveredIncludingChildren = true
      node.informParentsThatNodeIsHovered()

    node.drawProc = nil
    node.activeChildren.setLen(0)
    node.accessCount = 0

  if root.osWindow.isHovered:
    root.osWindow.setCursorStyle(root.activeCursorStyle)

  root.mousePresses.setLen(0)
  root.mouseReleases.setLen(0)
  root.keyPresses.setLen(0)
  root.keyReleases.setLen(0)
  root.textInput.setLen(0)
  root.mouseWheel = vec2(0, 0)
  root.globalMousePositionPrevious = root.globalMousePosition

template onFrame*(root: GuiRoot, code: untyped): untyped =
  root.onFrameProc = proc(argGui: GuiRoot) =
    {.hint[XDeclaredButNotUsed]: off.}
    let `root` {.inject.} = argGui
    code

proc run*(root: GuiRoot) =
  root.osWindow.run()


# =================================================================================
# Placement
# =================================================================================


proc anchor*(x: GuiAnchorX, y: GuiAnchorY): GuiAnchor =
  GuiAnchor(x: x, y: y)

proc placement*(node: GuiNode): GuiPlacement =
  GuiPlacement(
    anchor: node.anchor,
    position: node.position,
    size: node.size,
  )

proc `placement=`*(node: GuiNode, value: GuiPlacement) =
  node.anchor = value.anchor
  node.position = value.position
  node.size = value.size


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