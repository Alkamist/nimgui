{.experimental: "overloadableEnums".}

import ./math; export math
import ./windowbase; export windowbase
import ./drawlist; export drawlist

type
  GuiView* = ref object
    isRoot*: bool
    childViews*: seq[GuiView]
    inputState*: InputState
    root {.cursor.}: GuiView
    rootHover {.cursor.}: GuiView

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

proc getHover(view: GuiView): GuiView =
  for i in countdown(view.childViews.len - 1, 0, 1):
    let child = view.childViews[i]
    let childBounds = rect2(child.position, child.size)
    if childBounds.contains(view.mousePosition):
      let hoverOfChild = child.getHover()
      if hoverOfChild != nil:
        return hoverOfChild
      else:
        return child

proc update*(view: GuiView, gfx: DrawList) =
  gfx.translate(view.position)
  gfx.pushClipRect(rect2(vec2(0, 0), vec2(view.width, view.height)))

  if view.isRoot:
    view.root = view
    view.rootHover = view.getHover()

  for child in view.childViews:
    child.root = view.root
    child.rootHover = view.rootHover
    child.inputState.isHovered = view.rootHover == child
    child.inputState.pixelDensity = view.inputState.pixelDensity
    child.inputState.keyPresses = view.inputState.keyPresses
    child.inputState.keyReleases = view.inputState.keyReleases
    child.inputState.keyIsDown = view.inputState.keyIsDown
    child.inputState.text = view.inputState.text
    child.inputState.mousePosition = view.inputState.mousePosition - child.inputState.position
    child.inputState.mouseReleases = view.inputState.mouseReleases
    if child.inputState.isHovered:
      child.inputState.mouseWheel = child.root.inputState.mouseWheel
      child.inputState.mousePresses = child.root.inputState.mousePresses
      child.inputState.mouseIsDown = child.root.inputState.mouseIsDown

    child.update(gfx)

  gfx.translate(-view.position)
  gfx.popClipRect()
  view.updateInputState()