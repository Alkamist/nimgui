{.experimental: "overloadableEnums".}

import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  GuiWidget* = ref object of RootObj
    gui* {.cursor.}: Gui
    parent* {.cursor.}: GuiLayer
    dontDraw*: bool
    passInput*: bool
    isHovered*: bool
    position*: Vec2
    size*: Vec2

  GuiLayer* = ref object of GuiWidget
    mousePosition*: Vec2
    children*: seq[GuiWidget]

  Gui* = ref object of GuiLayer
    osWindow*: OsWindow
    renderer*: DrawListRenderer
    drawList*: DrawList
    hovers*: seq[GuiWidget]
    storedBackgroundColor: Color

method update*(widget: GuiWidget) {.base.} = discard
method draw*(widget: GuiWidget) {.base.} = discard

template bounds*(widget: GuiWidget): Rect2 = rect2(widget.position, widget.size)
template x*(widget: GuiWidget): float = widget.position.x
template `x=`*(widget: GuiWidget, value: float) = widget.position.x = value
template y*(widget: GuiWidget): float = widget.position.y
template `y=`*(widget: GuiWidget, value: float) = widget.position.y = value
template width*(widget: GuiWidget): float = widget.size.x
template `width=`*(widget: GuiWidget, value: float) = widget.size.x = value
template height*(widget: GuiWidget): float = widget.size.y
template `height=`*(widget: GuiWidget, value: float) = widget.size.y = value

template isOpen*(gui: Gui): bool = gui.osWindow.isOpen
template update*(gui: Gui): untyped = gui.osWindow.update()
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

func addWidget*(layer: GuiLayer, T: typedesc): T =
  result = T()
  result.gui = layer.gui
  result.parent = layer
  layer.children.add(result)

func isHoveredIncludingChildren*(layer: GuiLayer): bool =
  if layer.isHovered:
    return true
  for child in layer.children:
    if child of GuiLayer:
      if GuiLayer(child).isHoveredIncludingChildren:
        return true
    else:
      if child.isHovered:
        return true

func drawChildren*(layer: GuiLayer) =
  let gfx = layer.gui.drawList
  gfx.translate(layer.position)
  for child in layer.children:
    if not child.dontDraw:
      child.draw()
  gfx.translate(-layer.position)

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

proc newGui*(): Gui =
  result = Gui()
  result.osWindow = newOsWindow()
  result.renderer = newDrawListRenderer()
  result.drawList = newDrawList()
  result.gui = result

func childMouseHitTest(layer: GuiLayer): seq[GuiWidget] =
  for child in layer.children:
    let childBounds = child.bounds
    if childBounds.contains(layer.mousePosition):
      result.add(child)
      if child of GuiLayer:
        let hitTest = GuiLayer(child).childMouseHitTest()
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

func updateChildInput(layer: GuiLayer) =
  let gui = layer.gui
  for child in layer.children:
    child.isHovered = child in gui.hovers
    if child of GuiLayer:
      let childAsLayer = GuiLayer(child)
      childAsLayer.mousePosition = gui.mousePosition - child.position
      childAsLayer.updateChildInput()

func updateInput(gui: Gui) =
  gui.isHovered = gui.hovers.contains(gui)
  gui.position = vec2(0, 0)
  gui.size = gui.osWindow.inputState.size
  gui.mousePosition = gui.osWindow.inputState.mousePosition
  gui.updateChildInput()

proc beginFrame*(gui: Gui) =
  gui.updateHovers()
  gui.updateInput()
  gui.drawList.clearCommands()
  gui.renderer.beginFrame(gui.osWindow.sizePixels, gui.osWindow.pixelDensity)

proc endFrame*(gui: Gui) =
  gui.drawChildren()
  gui.renderer.render(gui.drawList)
  gui.renderer.endFrame(gui.osWindow.sizePixels)

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()