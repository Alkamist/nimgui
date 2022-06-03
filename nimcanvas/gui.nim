{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import ./canvas

type
  # WindowTheme* = tuple
  #   headerHeight: float
  #   borderThickness: float
  #   cornerRadius: float
  #   colors: tuple[
  #     body: Color,
  #     header: Color,
  #     border: Color,
  #     headerText: Color,
  #   ]

  WidgetId* = Hash

  Widget* = ref object of RootObj
    parent*: WidgetContainer
    bounds*: Rect2
    relativePosition*: Vec2
    mouseIsOver*: bool
    isFocused*: bool

  WidgetContainer* = ref object of Widget
    children*: Table[WidgetId, Widget]
    mouseOver*: Widget
    focus*: Widget

  Gui* = ref object of WidgetContainer
    canvas*: Canvas

  ButtonSignal* = enum
    Down
    Pressed
    Released
    Clicked

  ButtonWidget* = ref object of Widget
    isDown*: bool

template position*(widget: Widget): Vec2 = widget.bounds.position
template `position=`*(widget: Widget, value: Vec2) = widget.bounds.position = value
template size*(widget: Widget): Vec2 = widget.bounds.size
template `size=`*(widget: Widget, value: Vec2) = widget.bounds.size = value

func newGui*(canvas: Canvas): Gui =
  Gui(canvas: canvas)

func newWidget(): Widget =
  Widget()

func getWidget*(container: WidgetContainer, id: WidgetId): Widget =
  if container.children.hasKey(id):
    container.children[id]
  else:
    let widget = newWidget()
    container.children[id] = widget
    widget

func getWidget*(container: WidgetContainer, label: string): Widget =
  container.getWidget(hash(label))

# func updateChildren*(container: WidgetContainer, canvas: Canvas) =
#   var mouseOverIsSet = false
#   var focusChanged = false
#   var focusIndex = 0

#   container.mouseOver = nil

#   for i in countup(0, container.children.len - 1, 1):
#     let child = container.children[i]

#     child.parent = container

#     child.position = container.position + child.relativePosition
#     child.position = child.position
#     child.size = child.size

#     let mouseIsInside = child.bounds.contains(canvas.mousePosition)

#     if not mouseOverIsSet and mouseIsInside and container.mouseIsOver:
#       container.mouseOver = child
#       mouseOverIsSet = true

#     child.mouseIsOver = child == container.mouseOver

#     if child.mouseIsOver and canvas.mousePressed(Left):
#       container.focus = child
#       focusChanged = true
#       focusIndex = i

#     if container.focus == child and canvas.mousePressed(Left):
#       container.focus = nil

#   # Order children by most recently focused. That way you can
#   # draw them in reverse, which feels like the most natural
#   # way for windows to work.
#   if focusChanged:
#     for i in countdown(focusIndex, 1, 1):
#       container.children[i] = container.children[i - 1]
#     container.children[0] = container.focus

#   for i in countup(0, container.children.len - 1, 1):
#     let child = container.children[i]
#     child.isFocused = container.focus == child
#     if child of WidgetContainer:
#       WidgetContainer(child).updateChildren(canvas)

func beginFrame*(gui: Gui) =
  gui.size = gui.canvas.size
  gui.updateChildren(gui.canvas)

func drawFrameWithoutHeader(canvas: Canvas,
                            bounds: Rect2,
                            borderThickness: float,
                            cornerRadius: float,
                            bodyColor, borderColor: Color) =
  let scale = canvas.scale
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(scale)

  let leftOuter = bounds.x
  let leftMiddle = leftOuter + halfBorderThickness
  let leftInner = leftMiddle + halfBorderThickness
  let rightOuter = bounds.x + bounds.width
  let rightMiddle = rightOuter - halfBorderThickness
  let rightInner = rightMiddle - halfBorderThickness
  let topOuter = bounds.y
  let topMiddle = topOuter + halfBorderThickness
  let topInner = topMiddle + halfBorderThickness
  let bottomOuter = bounds.y + bounds.height
  let bottomMiddle = bottomOuter - halfBorderThickness
  let bottomInner = bottomMiddle - halfBorderThickness

  let outerCornerRadius = cornerRadius
  let middleCornerRadius = outerCornerRadius - halfBorderThickness
  let innerCornerRadius = middleCornerRadius - halfBorderThickness

  # Body fill.
  canvas.beginPath()
  canvas.roundedRect(
    rect2(
      leftMiddle,
      topMiddle,
      rightMiddle - leftMiddle,
      bottomMiddle - topMiddle,
    ),
    middleCornerRadius,
    middleCornerRadius,
    middleCornerRadius,
    middleCornerRadius,
  )
  canvas.fillColor = bodyColor
  canvas.fill()

  # Border outer.
  canvas.beginPath()
  canvas.roundedRect(bounds, cornerRadius)

  # Body inner hole.
  canvas.roundedRect(
    rect2(
      leftInner,
      topInner,
      rightInner - leftInner,
      bottomInner - topInner,
    ),
    innerCornerRadius,
    innerCornerRadius,
    innerCornerRadius,
    innerCornerRadius,
  )
  canvas.pathWinding = Hole

  canvas.fillColor = borderColor
  canvas.fill()

func drawFrameWithHeader(canvas: Canvas,
                         bounds: Rect2,
                         borderThickness, headerHeight: float,
                         cornerRadius: float,
                         bodyColor, headerColor, borderColor: Color) =
  let scale = canvas.scale
  let headerHeight = headerHeight.pixelAlign(scale)
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(scale)

  let leftOuter = bounds.x
  let leftMiddle = leftOuter + halfBorderThickness
  let leftInner = leftMiddle + halfBorderThickness
  let rightOuter = bounds.x + bounds.width
  let rightMiddle = rightOuter - halfBorderThickness
  let rightInner = rightMiddle - halfBorderThickness
  let topOuter = bounds.y
  let topMiddle = topOuter + halfBorderThickness
  let topInner = topMiddle + halfBorderThickness
  let headerOuter = bounds.y + headerHeight
  let headerMiddle = headerOuter - halfBorderThickness
  let headerInner = headerMiddle - halfBorderThickness
  let bottomOuter = bounds.y + bounds.height
  let bottomMiddle = bottomOuter - halfBorderThickness
  let bottomInner = bottomMiddle - halfBorderThickness

  let innerWidth = rightInner - leftInner
  let middleWidth = rightMiddle - leftMiddle

  let outerCornerRadius = cornerRadius
  let middleCornerRadius = outerCornerRadius - halfBorderThickness
  let innerCornerRadius = middleCornerRadius - halfBorderThickness

  # Header fill.
  canvas.beginPath()
  canvas.roundedRect(
    rect2(
      leftMiddle,
      topMiddle,
      middleWidth,
      headerMiddle - topMiddle,
    ),
    middleCornerRadius,
    middleCornerRadius,
    0, 0,
  )
  canvas.fillColor = headerColor
  canvas.fill()

  # Body fill.
  canvas.beginPath()
  canvas.roundedRect(
    rect2(
      leftMiddle,
      headerMiddle,
      middleWidth,
      bottomMiddle - headerMiddle,
    ),
    0, 0,
    middleCornerRadius,
    middleCornerRadius,
  )
  canvas.fillColor = bodyColor
  canvas.fill()

  # Border outer.
  canvas.beginPath()
  canvas.roundedRect(bounds, cornerRadius)

  # Header inner hole.
  canvas.roundedRect(
    rect2(
      leftInner,
      topInner,
      innerWidth,
      headerInner - topInner,
    ),
    innerCornerRadius,
    innerCornerRadius,
    0, 0,
  )
  canvas.pathWinding = Hole

  # Body inner hole.
  canvas.roundedRect(
    rect2(
      leftInner,
      headerOuter,
      innerWidth,
      bottomInner - headerOuter,
    ),
    0, 0,
    innerCornerRadius,
    innerCornerRadius,
  )
  canvas.pathWinding = Hole

  canvas.fillColor = borderColor
  canvas.fill()

# You need to break drawing up into commands so that they can be
# reordered later.
func button*(gui: Gui, label: string): set[ButtonSignal] =
  let canvas = gui.canvas
  let button = cast[ButtonWidget](gui.getWidget(label))

  button.bounds = rect2(50, 50, 97, 32)

  result.incl Down

  if button.mouseIsOver and canvas.mousePressed(Left):
    button.isDown = true
    result.incl Pressed

  if button.isDown and canvas.mouseReleased(Left):
    button.isDown = false
    result.incl Released
    if button.mouseIsOver:
      result.incl Clicked

  canvas.drawFrameWithoutHeader(
    bounds = button.bounds,
    borderThickness = 1.0,
    cornerRadius = 5.0,
    bodyColor = rgb(33, 38, 45),
    borderColor = rgb(52, 59, 66),
  )

  canvas.fontSize = 13
  canvas.fillColor = rgb(201, 209, 217)
  canvas.drawText(
    text = canvas.newText(label),
    bounds = button.bounds,
    alignX = Center,
    alignY = Center,
    wordWrap = false,
    clip = true,
  )

# func defaultWindowTheme*(): WindowTheme =
#   (
#     headerHeight: 24.0,
#     borderThickness: 1.0,
#     cornerRadius: 5.0,
#     colors: (
#       body: rgb(13, 17, 23),
#       header: rgb(22, 27, 34),
#       border: rgb(52, 59, 66),
#       headerText: rgb(201, 209, 217),
#     ),
#   )

# func beginWindow*(gui: Gui, label: string) =
#   let canvas = gui.canvas
#   let theme = defaultWindowTheme()

#   canvas.drawFrameWithHeader(
#     bounds = rect2(50, 50, 200, 200),
#     theme.borderThickness,
#     theme.headerHeight,
#     theme.cornerRadius,
#     theme.colors.body,
#     theme.colors.header,
#     theme.colors.border,
#   )

# func endWindow*(gui: Gui) =
#   let canvas = gui.canvas
#   canvas.resetClip()
#   canvas.restoreState()