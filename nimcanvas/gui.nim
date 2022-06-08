{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
# import ./gui/widget; export widget
import ./input; export input
import ./math; export math
import ./vg; export vg

type
  WidgetId* = Hash

  WindowWidget* = ref object
    context*: VgContext
    bounds*: Rect2
    isHovered*: bool
    isBeingMoved*: bool

  Gui* = ref object
    input*: Input
    windows*: Table[WidgetId, WindowWidget]
    windowStack*: seq[WidgetId]
    windowFocusOrder*: seq[WidgetId]

proc getWindow*(gui: Gui, id: WidgetId): WindowWidget =
  if gui.windows.hasKey(id):
    result = gui.windows[id]
  else:
    result = WindowWidget(
      context: newVgContext(),
      bounds: rect2(50, 50, 400, 300),
    )
    gui.windows[id] = result
    gui.windowFocusOrder.add id
  gui.windowStack.add id
  result.context.beginFrame(gui.input.size * gui.input.pixelDensity, gui.input.scale)

proc getWindow*(gui: Gui, label: string): WindowWidget =
  gui.getWindow(hash(label))

func newGui*(input: Input): Gui =
  Gui(input: input)

proc beginFrame*(gui: Gui) =
  gui.windowStack.setLen(0)

proc endFrame*(gui: Gui) =
  var hoverIsSet = false
  for i in countdown(gui.windowFocusOrder.len - 1, 0, 1):
    let window = gui.windows[gui.windowFocusOrder[i]]
    window.context.endFrame()
    if not hoverIsSet and window.bounds.contains(gui.input.mousePosition):
      window.isHovered = true
      hoverIsSet = true
    else:
      window.isHovered = false

func drawFrameWithoutHeader(ctx: VgContext,
                            bounds: Rect2,
                            borderThickness: float,
                            cornerRadius: float,
                            bodyColor, borderColor: Color) =
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(ctx)

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
  ctx.beginPath()
  ctx.roundedRect(
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
  ctx.fillColor = bodyColor
  ctx.fill()

  # Border outer.
  ctx.beginPath()
  ctx.roundedRect(bounds, cornerRadius)

  # Body inner hole.
  ctx.roundedRect(
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
  ctx.pathWinding = Hole

  ctx.fillColor = borderColor
  ctx.fill()

func drawFrameWithHeader(ctx: VgContext,
                         bounds: Rect2,
                         borderThickness, headerHeight: float,
                         cornerRadius: float,
                         bodyColor, headerColor, borderColor: Color) =
  let headerHeight = headerHeight.pixelAlign(ctx)
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(ctx)

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
  ctx.beginPath()
  ctx.roundedRect(
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
  ctx.fillColor = headerColor
  ctx.fill()

  # Body fill.
  ctx.beginPath()
  ctx.roundedRect(
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
  ctx.fillColor = bodyColor
  ctx.fill()

  # Border outer.
  ctx.beginPath()
  ctx.roundedRect(bounds, cornerRadius)

  # Header inner hole.
  ctx.roundedRect(
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
  ctx.pathWinding = Hole

  # Body inner hole.
  ctx.roundedRect(
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
  ctx.pathWinding = Hole

  ctx.fillColor = borderColor
  ctx.fill()

# type
#   ButtonSignal* = enum
#     Down
#     Pressed
#     Released
#     Clicked

# func button*(gui: Gui, label: string): set[ButtonSignal] =
#   let button = cast[ButtonWidget](gui.getWidget(label))
#   let ctx = gui.ctx
#   let input = gui.input

#   button.bounds = rect2(50, 50, 97, 32)

#   result.incl Down

#   if button.mouseIsOver and input.mousePressed(Left):
#     button.isDown = true
#     result.incl Pressed

#   if button.isDown and input.mouseReleased(Left):
#     button.isDown = false
#     result.incl Released
#     if button.mouseIsOver:
#       result.incl Clicked

#   ctx.drawFrameWithoutHeader(
#     bounds = button.bounds,
#     borderThickness = 1.0,
#     cornerRadius = 5.0,
#     bodyColor = rgb(33, 38, 45),
#     borderColor = rgb(52, 59, 66),
#   )

#   ctx.fontSize = 13
#   ctx.fillColor = rgb(201, 209, 217)
#   ctx.drawText(
#     text = ctx.newText(label),
#     bounds = button.bounds,
#     alignX = Center,
#     alignY = Center,
#     wordWrap = false,
#     clip = true,
#   )

func defaultWindowTheme*(): auto =
  (
    headerHeight: 24.0,
    borderThickness: 1.0,
    cornerRadius: 5.0,
    colors: (
      body: rgb(13, 17, 23),
      header: rgb(22, 27, 34),
      border: rgb(52, 59, 66),
      headerText: rgb(201, 209, 217),
    ),
  )

proc beginWindow*(gui: Gui, label: string) =
  let theme = defaultWindowTheme()
  let input = gui.input
  let window = gui.getWindow(label)
  let ctx = window.context

  if window.isHovered and input.mousePressed(Left):
    window.isBeingMoved = true

  if window.isBeingMoved and input.mouseReleased(Left):
    window.isBeingMoved = false

  if window.isBeingMoved:
    window.bounds.position += input.mouseDelta

  ctx.drawFrameWithHeader(
    bounds = window.bounds,
    theme.borderThickness,
    theme.headerHeight,
    theme.cornerRadius,
    theme.colors.body,
    theme.colors.header,
    theme.colors.border,
  )

func endWindow*(gui: Gui) =
  discard