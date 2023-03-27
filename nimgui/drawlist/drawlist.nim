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
    ResetClip
    Rect
    RoundedRect
    SetFillColor
    SetPathWinding
    Clip

  DrawCommand* = object
    case kind*: DrawCommandKind
    of BeginPath .. ResetClip: discard
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
    of Clip: clip*: tuple[
      rect: Rect2,
      intersect: bool,
    ]

  DrawList* = ref object
    commands*: seq[DrawCommand]

func newDrawList*(): DrawList = DrawList()
func clearCommands*(drawList: DrawList) = drawList.commands.setLen(0)

func beginPath*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: BeginPath)
func closePath*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: ClosePath)
func fill*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: Fill)
func resetClip*(drawList: DrawList) = drawList.commands.add DrawCommand(kind: ResetClip)

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

func clip*(drawList: DrawList, rect: Rect2, intersect = true) =
  drawList.commands.add DrawCommand(kind: Clip, clip: (
    rect: rect,
    intersect: intersect,
  ))