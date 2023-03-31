{.experimental: "overloadableEnums".}

import std/tables
import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  GuiId* = string

  GuiWidget* = ref object of RootObj
    isHovered*: bool
    justCreated*: bool
    passInput*: bool
    position*: Vec2
    size*: Vec2

  GuiLayer* = ref object of GuiWidget
    # mouseIsCaptured*: bool
    mousePosition*: Vec2
    widgets*: Table[GuiId, GuiWidget]
    widgetZOrder*: seq[GuiWidget]

  Gui* = ref object
    osWindow*: OsWindow
    renderer*: DrawListRenderer
    gfx*: DrawList
    rootLayer*: GuiLayer
    layerStack*: seq[GuiLayer]
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

template currentLayer*(gui: Gui): GuiLayer = gui.layerStack[^1]
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
template mousePosition*(gui: Gui): Vec2 = gui.osWindow.mousePosition
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

func backgroundColor*(gui: Gui): Color =
  gui.storedBackgroundColor

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.osWindow.backgroundColor = color
  gui.storedBackgroundColor = color

proc newGui*(): Gui =
  result = Gui()
  result.osWindow = newOsWindow()
  result.renderer = newDrawListRenderer()
  result.gfx = newDrawList()
  result.rootLayer = GuiLayer()
  result.rootLayer.justCreated = true

func childMouseHitTest(layer: GuiLayer): seq[GuiWidget] =
  for child in layer.widgetZOrder:
    let childBounds = child.bounds
    if childBounds.contains(layer.mousePosition):
      result.add(child)
      if child of GuiLayer:
        let hitTest = GuiLayer(child).childMouseHitTest()
        for hit in hitTest:
          result.add(hit)

proc updateHovers(gui: Gui) =
  gui.hovers.setLen(0)
  let childHitTest = gui.rootLayer.childMouseHitTest()
  for i in countdown(childHitTest.len - 1, 0, 1):
    let hit = childHitTest[i]
    gui.hovers.add(hit)
    if not hit.passInput:
      return
  if gui.rootLayer.bounds.contains(gui.osWindow.mousePosition):
    gui.hovers.add(gui.rootLayer)

proc updateRootInput(gui: Gui) =
  gui.rootLayer.isHovered = gui.hovers.contains(gui.rootLayer)
  gui.rootLayer.position = vec2(0, 0)
  gui.rootLayer.size = gui.osWindow.inputState.size
  gui.rootLayer.mousePosition = gui.osWindow.inputState.mousePosition - gui.rootLayer.position

proc beginLayer*(gui: Gui, id: GuiId): GuiLayer {.discardable.} =
  let parentLayer = gui.currentLayer

  if not parentLayer.widgets.hasKey(id):
    result = GuiLayer()
    result.justCreated = true
    parentLayer.widgets[id] = result
    parentLayer.widgetZOrder.add result
  else:
    result = GuiLayer(parentLayer.widgets[id])
    result.justCreated = false

  result.isHovered = gui.hovers.contains(result)
  result.mousePosition = parentLayer.mousePosition - result.position

  gui.layerStack.add result

  let gfx = gui.gfx
  gfx.translate(result.position)
  gfx.pushClipRect(rect2(vec2(0, 0), result.size))

proc endLayer*(gui: Gui) =
  let gfx = gui.gfx
  let layer = gui.currentLayer
  gfx.translate(-layer.position)
  gfx.popClipRect()
  if gui.layerStack.len <= 1:
    raise newException(Exception, "endLayer called when the layer stack only had the root left in it. Too many endLayer calls?")
  gui.layerStack.setLen(gui.layerStack.len - 1)

proc addWidget*(gui: Gui, id: GuiId, T: typedesc): T =
  let parentLayer = gui.currentLayer

  if not parentLayer.widgets.hasKey(id):
    result = T()
    result.justCreated = true
    parentLayer.widgets[id] = result
    parentLayer.widgetZOrder.add result
  else:
    result = T(parentLayer.widgets[id])
    result.justCreated = false

  result.isHovered = gui.hovers.contains(result)

proc beginFrame*(gui: Gui) =
  gui.layerStack = @[gui.rootLayer]
  gui.updateHovers()
  gui.updateRootInput()
  gui.renderer.beginFrame(gui.osWindow.sizePixels, gui.osWindow.pixelDensity)
  gui.gfx.clearCommands()

proc endFrame*(gui: Gui) =
  if gui.layerStack.len > 1:
    raise newException(Exception, "endFrame called with more layers than the root. Too few endLayer calls?")
  gui.renderer.render(gui.gfx)
  gui.renderer.endFrame(gui.osWindow.sizePixels)
  gui.rootLayer.justCreated = false

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()