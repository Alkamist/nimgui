{.experimental: "overloadableEnums".}

import std/hashes
# import std/tables
import ./input; export input
import ./math; export math
import ./vg; export vg

type
  WidgetId* = Hash

  WidgetContainer* = ref object of RootObj

  Gui* = ref object
    input*: Input
    mouseOverWidget*: WidgetId
    focusedWindow*: WidgetId
    containerStack*: seq[WidgetId]

func newGui*(input: Input): Gui =
  Gui(input: input)

func mouseIsOver*(gui: Gui, id: WidgetId): bool =
  gui.mouseOverWidget == id

func beginFrame*(gui: Gui) =
  let input = gui.input

# func beginFrame*(gui: Gui) =
#   let input = gui.input

#   var mouseOverIsSet = false
#   var focusChanged = false
#   var focusIndex = 0

#   container.mouseOver = nil

#   for i in countup(0, container.children.len - 1, 1):
#     let child = container.children[i]

#     child.bounds.position = container.bounds.position + child.relativePosition

#     let mouseIsInside = child.bounds.contains(input.mousePosition)

#     if not mouseOverIsSet and mouseIsInside and container.mouseIsOver:
#       container.mouseOver = child
#       mouseOverIsSet = true

#     child.mouseIsOver = child == container.mouseOver

#     if child.mouseIsOver and input.mousePressed(Left):
#       container.focus = child
#       focusChanged = true
#       focusIndex = i

#     if container.focus == child and input.mousePressed(Left):
#       container.focus = nil

#   # Order children by most recently focused. That way you can
#   # draw them in reverse, which feels like the most natural
#   # way for windows to work.
#   # if focusChanged:
#   #   for i in countdown(focusIndex, 1, 1):
#   #     container.children[i] = container.children[i - 1]
#   #   container.children[0] = container.focus

#   for i in countup(0, container.children.len - 1, 1):
#     let child = container.children[i]
#     child.isFocused = container.focus == child
#     if child of WidgetContainer:
#       let childAsContainer = WidgetContainer(child)
#       childAsContainer.input = input
#       childAsContainer.updateChildren()

func drawFrameWithoutHeader(vg: VgContext,
                            bounds: Rect2,
                            borderThickness: float,
                            cornerRadius: float,
                            bodyColor, borderColor: Color) =
  let halfBorderThickness = borderThickness * 0.5
  let bounds = bounds.pixelAlign(vg)

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
  vg.beginPath()
  vg.roundedRect(
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
  vg.fillColor = bodyColor
  vg.fill()

  # Border outer.
  vg.beginPath()
  vg.roundedRect(bounds, cornerRadius)

  # Body inner hole.
  vg.roundedRect(
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
  vg.pathWinding = Hole

  vg.fillColor = borderColor
  vg.fill()

# func drawFrameWithHeader(canvas: Canvas,
#                          bounds: Rect2,
#                          borderThickness, headerHeight: float,
#                          cornerRadius: float,
#                          bodyColor, headerColor, borderColor: Color) =
#   let scale = canvas.scale
#   let headerHeight = headerHeight.pixelAlign(scale)
#   let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
#   let halfBorderThickness = borderThickness * 0.5
#   let bounds = bounds.pixelAlign(scale)

#   let leftOuter = bounds.x
#   let leftMiddle = leftOuter + halfBorderThickness
#   let leftInner = leftMiddle + halfBorderThickness
#   let rightOuter = bounds.x + bounds.width
#   let rightMiddle = rightOuter - halfBorderThickness
#   let rightInner = rightMiddle - halfBorderThickness
#   let topOuter = bounds.y
#   let topMiddle = topOuter + halfBorderThickness
#   let topInner = topMiddle + halfBorderThickness
#   let headerOuter = bounds.y + headerHeight
#   let headerMiddle = headerOuter - halfBorderThickness
#   let headerInner = headerMiddle - halfBorderThickness
#   let bottomOuter = bounds.y + bounds.height
#   let bottomMiddle = bottomOuter - halfBorderThickness
#   let bottomInner = bottomMiddle - halfBorderThickness

#   let innerWidth = rightInner - leftInner
#   let middleWidth = rightMiddle - leftMiddle

#   let outerCornerRadius = cornerRadius
#   let middleCornerRadius = outerCornerRadius - halfBorderThickness
#   let innerCornerRadius = middleCornerRadius - halfBorderThickness

#   # Header fill.
#   canvas.beginPath()
#   canvas.roundedRect(
#     rect2(
#       leftMiddle,
#       topMiddle,
#       middleWidth,
#       headerMiddle - topMiddle,
#     ),
#     middleCornerRadius,
#     middleCornerRadius,
#     0, 0,
#   )
#   canvas.fillColor = headerColor
#   canvas.fill()

#   # Body fill.
#   canvas.beginPath()
#   canvas.roundedRect(
#     rect2(
#       leftMiddle,
#       headerMiddle,
#       middleWidth,
#       bottomMiddle - headerMiddle,
#     ),
#     0, 0,
#     middleCornerRadius,
#     middleCornerRadius,
#   )
#   canvas.fillColor = bodyColor
#   canvas.fill()

#   # Border outer.
#   canvas.beginPath()
#   canvas.roundedRect(bounds, cornerRadius)

#   # Header inner hole.
#   canvas.roundedRect(
#     rect2(
#       leftInner,
#       topInner,
#       innerWidth,
#       headerInner - topInner,
#     ),
#     innerCornerRadius,
#     innerCornerRadius,
#     0, 0,
#   )
#   canvas.pathWinding = Hole

#   # Body inner hole.
#   canvas.roundedRect(
#     rect2(
#       leftInner,
#       headerOuter,
#       innerWidth,
#       bottomInner - headerOuter,
#     ),
#     0, 0,
#     innerCornerRadius,
#     innerCornerRadius,
#   )
#   canvas.pathWinding = Hole

#   canvas.fillColor = borderColor
#   canvas.fill()

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