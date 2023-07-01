import ./vec2

type
  PathWinding* = enum
    Positive
    Negative

  PathCommandKind* = enum
    Close
    Rect
    RoundedRect
    MoveTo
    LineTo
    ArcTo
    Winding

  RectCommand* = object
    position*, size*: Vec2

  RoundedRectCommand* = object
    position*, size*: Vec2
    rTopLeft*, rTopRight*: float
    rBottomRight*, rBottomLeft*: float

  MoveToCommand* = object
    position*: Vec2

  LineToCommand* = object
    position*: Vec2

  ArcToCommand* = object
    p0*, p1*: Vec2
    radius*: float

  WindingCommand* = object
    winding*: PathWinding

  PathCommand* = object
    case kind*: PathCommandKind
    of Close: discard
    of Rect: rect*: RectCommand
    of RoundedRect: roundedRect*: RoundedRectCommand
    of MoveTo: moveTo*: MoveToCommand
    of LineTo: lineTo*: LineToCommand
    of ArcTo: arcTo*: ArcToCommand
    of Winding: winding*: WindingCommand

  Path* = ref object
    commands*: seq[PathCommand]

proc clear*(path: Path) =
  path.commands.setLen(0)

proc close*(path: Path) =
  path.commands.add(PathCommand(kind: Close))

proc moveTo*(path: Path, position: Vec2) =
  path.commands.add(PathCommand(kind: MoveTo, moveTo: MoveToCommand(position: position)))

proc lineTo*(path: Path, position: Vec2) =
  path.commands.add(PathCommand(kind: LineTo, lineTo: LineToCommand(position: position)))

proc arcTo*(path: Path, p0, p1: Vec2, radius: float) =
  path.commands.add(PathCommand(kind: ArcTo, arcTo: ArcToCommand(p0: p0, p1: p1, radius: radius)))

proc rect*(path: Path, position, size: Vec2, winding = PathWinding.Positive) =
  path.commands.add(PathCommand(kind: Rect, rect: RectCommand(position: position, size: size)))
  path.commands.add(PathCommand(kind: Winding, winding: WindingCommand(winding: winding)))

proc roundedRect*(path: Path, position, size: Vec2, rTopLeft, rTopRight, rBottomRight, rBottomLeft: float, winding = PathWinding.Positive) =
  path.commands.add(PathCommand(kind: RoundedRect, roundedRect: RoundedRectCommand(
    position: position, size: size,
    rTopLeft: rTopLeft, rTopRight: rTopRight,
    rBottomRight: rBottomRight,
    rBottomLeft: rBottomLeft,
  )))
  path.commands.add(PathCommand(kind: Winding, winding: WindingCommand(winding: winding)))

proc roundedRect*(path: Path, position, size: Vec2, rounding: float, winding = PathWinding.Positive) =
  path.roundedRect(position, size, rounding, rounding, rounding, rounding, winding)