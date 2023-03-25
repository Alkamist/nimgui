{.experimental: "overloadableEnums".}

import ../math; export math

type
  Winding* = enum
    CounterClockwise
    Clockwise

  PathWinding* = enum
    CounterClockwise
    Clockwise
    Solid
    Hole

  LineCap* = enum
    Butt
    Round
    Square

  LineJoin* = enum
    Round
    Bevel
    Miter

  DrawCommandKind* = enum
    BeginPath
    ClosePath
    Fill
    Rect
    RoundedRect
    SetFillColor
    SetPathWinding

  DrawCommand* = object
    case kind*: DrawCommandKind
    of BeginPath .. Fill: discard
    of Rect: rect*: tuple[
      rect: Rect2,
    ]
    of RoundedRect: roundedRect*: tuple[
      rect: Rect2,
      topLeftRadius, topRightRadius: float,
      bottomRightRadius, bottomLeftRadius: float,
    ]
    of SetFillColor: setFillColor*: tuple[
      color: Color,
    ]
    of SetPathWinding: setPathWinding*: tuple[
      winding: PathWinding,
    ]

  DrawList* = ref object
    commands*: seq[DrawCommand]

func newDrawList*(): DrawList = DrawList()
func clearCommands*(drawList: DrawList) = drawList.commands.setLen(0)

func beginPath*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: BeginPath)
func closePath*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: ClosePath)
func fill*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: Fill)

func rect*(drawList: DrawList, rect: Rect2) =
  drawList.commands.add DrawCommand(kind: Rect, rect: (
    rect: rect,
  ))

func roundedRect*(drawList: DrawList, rect: Rect2, topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius: float) =
  drawList.commands.add DrawCommand(kind: RoundedRect, roundedRect: (
    rect: rect,
    topLeftRadius: topLeftRadius, topRightRadius: topRightRadius,
    bottomRightRadius: bottomRightRadius, bottomLeftRadius: bottomLeftRadius,
  ))

func roundedRect*(drawList: DrawList, rect: Rect2, radius: float) =
  drawList.roundedRect(rect, radius, radius, radius, radius)

func `fillColor=`*(drawList: DrawList, color: Color) =
  drawList.commands.add DrawCommand(kind: SetFillColor, setFillColor: (
    color: color,
  ))

func `pathWinding=`*(drawList: DrawList, winding: PathWinding) =
  drawList.commands.add DrawCommand(kind: SetPathWinding, setPathWinding: (
    winding: winding,
  ))

func drawFrame*(drawList: DrawList,
                bounds: Rect2,
                borderThickness: float,
                cornerRadius: float,
                bodyColor, borderColor: Color) =
  let gfx = drawList
  let halfBorderThickness = borderThickness * 0.5

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
  gfx.beginPath()
  gfx.roundedRect(
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
  gfx.fillColor = bodyColor
  gfx.fill()

  # Border outer.
  gfx.beginPath()
  gfx.roundedRect(bounds, cornerRadius)

  # Body inner hole.
  gfx.roundedRect(
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
  gfx.pathWinding = Hole

  gfx.fillColor = borderColor
  gfx.fill()

func drawFrameWithHeader*(drawList: DrawList,
                          bounds: Rect2,
                          borderThickness, headerHeight: float,
                          cornerRadius: float,
                          bodyColor, headerColor, borderColor: Color) =
  let gfx = drawList
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let halfBorderThickness = borderThickness * 0.5

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
  gfx.beginPath()
  gfx.roundedRect(
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
  gfx.fillColor = headerColor
  gfx.fill()

  # Body fill.
  gfx.beginPath()
  gfx.roundedRect(
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
  gfx.fillColor = bodyColor
  gfx.fill()

  # Border outer.
  gfx.beginPath()
  gfx.roundedRect(bounds, cornerRadius)

  # Header inner hole.
  gfx.roundedRect(
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
  gfx.pathWinding = Hole

  # Body inner hole.
  gfx.roundedRect(
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
  gfx.pathWinding = Hole

  gfx.fillColor = borderColor
  gfx.fill()