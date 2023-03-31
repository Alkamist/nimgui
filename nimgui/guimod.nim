{.experimental: "overloadableEnums".}

import std/tables
import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  GuiId* = string

  GuiWidget* = ref object of RootObj
    justCreated*: bool
    position*: Vec2
    size*: Vec2

  GuiView* = ref object
    inputState*: InputState
    childViews*: Table[GuiId, GuiView]
    childViewsZOrder*: seq[GuiView]
    childWidgets*: Table[GuiId, GuiWidget]

  Gui* = ref object
    osWindow*: OsWindow
    renderer*: DrawListRenderer
    gfx*: DrawList
    rootView*: GuiView
    hoverView*: GuiView
    viewStack*: seq[GuiView]
    storedBackgroundColor: Color

# -------------------- GuiWidget --------------------

template bounds*(widget: GuiWidget): auto = rect2(widget.position, widget.size)
template x*(widget: GuiWidget): auto = widget.position.x
template `x=`*(widget: GuiWidget, value: auto) = widget.position.x = value
template y*(widget: GuiWidget): auto = widget.position.y
template `y=`*(widget: GuiWidget, value: auto) = widget.position.y = value
template width*(widget: GuiWidget): auto = widget.size.x
template `width=`*(widget: GuiWidget, value: auto) = widget.size.x = value
template height*(widget: GuiWidget): auto = widget.size.y
template `height=`*(widget: GuiWidget, value: auto) = widget.size.y = value

# -------------------- GuiView --------------------

defineWindowBaseTemplates(GuiView)

template `position=`*(view: GuiView, value: auto) = view.inputState.position = value
template `x=`*(view: GuiView, value: auto) = view.inputState.position.x = value
template `y=`*(view: GuiView, value: auto) = view.inputState.position.y = value
template `size=`*(view: GuiView, value: auto) = view.inputState.size = value
template `width=`*(view: GuiView, value: auto) = view.inputState.size.x = value
template `height=`*(view: GuiView, value: auto) = view.inputState.size.y = value

proc newGuiView*(): GuiView =
  result = GuiView()
  result.initInputState()

func getHover(view: GuiView): GuiView =
  for i in countdown(view.childViewsZOrder.len - 1, 0, 1):
    let child = view.childViewsZOrder[i]
    let childBounds = rect2(child.position, child.size)
    if childBounds.contains(view.mousePosition):
      let hoverOfChild = child.getHover()
      if hoverOfChild != nil:
        return hoverOfChild
      else:
        return child

# -------------------- Gui --------------------

template isOpen*(gui: Gui): auto = gui.osWindow.isOpen
template update*(gui: Gui): untyped = gui.osWindow.update()

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
  result.rootView = newGuiView()

proc updateHover(gui: Gui) =
  let rootHover = gui.rootView.getHover()
  gui.hoverView =
    if rootHover != nil:
      rootHover
    else:
      gui.rootView

proc updateRootInput(gui: Gui) =
  gui.rootView.updateInputState()
  gui.rootView.inputState.isHovered = gui.hoverView == gui.rootView
  gui.rootView.inputState.pixelDensity = gui.osWindow.inputState.pixelDensity
  gui.rootView.inputState.position = vec2(0, 0)
  gui.rootView.inputState.size = gui.osWindow.inputState.size
  gui.rootView.inputState.mousePosition = gui.osWindow.inputState.mousePosition - gui.rootView.inputState.position
  gui.rootView.inputState.mouseReleases = gui.osWindow.inputState.mouseReleases
  gui.rootView.inputState.keyPresses = gui.osWindow.inputState.keyPresses
  gui.rootView.inputState.keyReleases = gui.osWindow.inputState.keyReleases
  gui.rootView.inputState.keyIsDown = gui.osWindow.inputState.keyIsDown
  gui.rootView.inputState.text = gui.osWindow.inputState.text
  if gui.rootView.inputState.isHovered:
    gui.rootView.inputState.mouseWheel = gui.osWindow.inputState.mouseWheel
    gui.rootView.inputState.mousePresses = gui.osWindow.inputState.mousePresses
    gui.rootView.inputState.mouseIsDown = gui.osWindow.inputState.mouseIsDown

proc updateChildViewInput(gui: Gui, view: GuiView) =
  for child in view.childViewsZOrder:
    child.updateInputState()
    child.inputState.isHovered = gui.hoverView == child
    child.inputState.pixelDensity = view.inputState.pixelDensity
    child.inputState.keyPresses = view.inputState.keyPresses
    child.inputState.keyReleases = view.inputState.keyReleases
    child.inputState.keyIsDown = view.inputState.keyIsDown
    child.inputState.text = view.inputState.text
    child.inputState.mousePosition = view.inputState.mousePosition - child.inputState.position
    child.inputState.mouseReleases = gui.osWindow.inputState.mouseReleases
    if child.inputState.isHovered:
      child.inputState.mouseWheel = gui.osWindow.inputState.mouseWheel
      child.inputState.mousePresses = gui.osWindow.inputState.mousePresses
      child.inputState.mouseIsDown = gui.osWindow.inputState.mouseIsDown

    gui.updateChildViewInput(child)

proc currentView*(gui: Gui): GuiView =
  gui.viewStack[^1]

proc beginView*(gui: Gui, id: GuiId): GuiView {.discardable.} =
  let gfx = gui.gfx

  if not gui.currentView.childViews.hasKey(id):
    result = GuiView()
    gui.currentView.childViews[id] = result
    gui.currentView.childViewsZOrder.add result
  else:
    result = gui.currentView.childViews[id]

  gui.viewStack.add result
  gfx.translate(result.position)
  gfx.pushClipRect(rect2(vec2(0, 0), result.size))

proc endView*(gui: Gui) =
  let gfx = gui.gfx
  let view = gui.currentView
  gfx.translate(-view.position)
  gfx.popClipRect()
  if gui.viewStack.len <= 1:
    raise newException(Exception, "endView called when the view stack only had the root left in it. Too many endView calls?")
  gui.viewStack.setLen(gui.viewStack.len - 1)

proc addWidget*(gui: Gui, id: GuiId, T: typedesc): T =
  let view = gui.currentView
  if not view.childWidgets.hasKey(id):
    result = T()
    result.justCreated = true
    view.childWidgets[id] = result
  else:
    result = T(view.childWidgets[id])
    result.justCreated = false

proc beginFrame*(gui: Gui) =
  gui.viewStack = @[gui.rootView]
  gui.updateHover()
  gui.updateRootInput()
  gui.updateChildViewInput(gui.rootView)
  gui.renderer.beginFrame(gui.rootView.sizePixels, gui.rootView.pixelDensity)
  gui.gfx.clearCommands()

proc endFrame*(gui: Gui) =
  if gui.viewStack.len > 1:
    raise newException(Exception, "endFrame called with more views than the root. Too few endView calls?")
  gui.renderer.render(gui.gfx)
  gui.renderer.endFrame(gui.rootView.sizePixels)

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()