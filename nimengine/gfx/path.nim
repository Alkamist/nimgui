{.experimental: "overloadableEnums".}

import std/math
import std/strutils

import ../tmath
export tmath

type
  PathError* = object of CatchableError

  PathCommandKind* = enum
    Close,
    Move, Line, HLine, VLine, Cubic, SCubic, Quad, TQuad, Arc,
    RMove, RLine, RHLine, RVLine, RCubic, RSCubic, RQuad, RTQuad, RArc,

  PathCommand* = object
    kind*: PathCommandKind
    numbers*: seq[float]

  Path* = ref object
    commands*: seq[PathCommand]
    # start*, at*: tuple[x, y: float]

func newPath*(): Path =
  Path()

template pathError*(msg: string) =
  raise newException(PathError, msg)

func isRelative*(kind: PathCommandKind): bool =
  kind in {
    RMove, RLine, TQuad, RTQuad, RHLine, RVLine, RCubic, RSCubic, RQuad, RArc
  }

func parameterCount*(kind: PathCommandKind): int =
  case kind:
  of Close: 0
  of Move, Line, RMove, RLine, TQuad, RTQuad: 2
  of HLine, VLine, RHLine, RVLine: 1
  of Cubic, RCubic: 6
  of SCubic, RSCubic, Quad, RQuad: 4
  of Arc, RArc: 7

func `$`*(path: Path): string =
  for i, command in path.commands:
    case command.kind
    of Move: result.add "M"
    of Line: result.add "L"
    of HLine: result.add "H"
    of VLine: result.add "V"
    of Cubic: result.add "C"
    of SCubic: result.add "S"
    of Quad: result.add "Q"
    of TQuad: result.add "T"
    of Arc: result.add "A"
    of RMove: result.add "m"
    of RLine: result.add "l"
    of RHLine: result.add "h"
    of RVLine: result.add "v"
    of RCubic: result.add "c"
    of RSCubic: result.add "s"
    of RQuad: result.add "q"
    of RTQuad: result.add "t"
    of RArc: result.add "a"
    of Close: result.add "Z"
    for j, number in command.numbers:
      if floor(number) == number:
        result.add $number.int
      else:
        result.add $number
      if i != path.commands.len - 1 or j != command.numbers.len - 1:
        result.add " "

func parsePath*(path: string): Path {.raises: [PathError].} =
  result = newPath()

  if path.len == 0:
    return

  var p, numberStart: int
  var armed, hitDecimal: bool
  var kind: PathCommandKind
  var numbers: seq[float]

  proc finishNumber() =
    if numberStart > 0:
      try:
        numbers.add(parseFloat(path[numberStart ..< p]))
      except ValueError:
        pathError "Invalid path, parsing parameter failed."
    numberStart = 0
    hitDecimal = false

  proc finishCommand(result: Path) =
    finishNumber()

    if armed: # The first finishCommand() arms
      let paramCount = parameterCount(kind)
      if paramCount == 0:
        if numbers.len != 0:
          pathError "Invalid path, unexpected parameters."
        result.commands.add(PathCommand(kind: kind))
      else:
        if numbers.len mod paramCount != 0:
          pathError "Invalid path, wrong number of parameters."
        for batch in 0 ..< numbers.len div paramCount:
          if batch > 0:
            if kind == Move:
              kind = Line
            elif kind == RMove:
              kind = RLine
          result.commands.add(PathCommand(
            kind: kind,
            numbers: numbers[batch * paramCount ..< (batch + 1) * paramCount]
          ))
        numbers.setLen(0)

    armed = true

  template expectsArcFlag(): bool =
    kind in {Arc, RArc} and numbers.len mod 7 in {3, 4}

  while p < path.len:
    case path[p]:
    # Relative
    of 'm':
      finishCommand(result)
      kind = RMove
    of 'l':
      finishCommand(result)
      kind = RLine
    of 'h':
      finishCommand(result)
      kind = RHLine
    of 'v':
      finishCommand(result)
      kind = RVLine
    of 'c':
      finishCommand(result)
      kind = RCubic
    of 's':
      finishCommand(result)
      kind = RSCubic
    of 'q':
      finishCommand(result)
      kind = RQuad
    of 't':
      finishCommand(result)
      kind = RTQuad
    of 'a':
      finishCommand(result)
      kind = RArc
    of 'z':
      finishCommand(result)
      kind = Close
    # Absolute
    of 'M':
      finishCommand(result)
      kind = Move
    of 'L':
      finishCommand(result)
      kind = Line
    of 'H':
      finishCommand(result)
      kind = HLine
    of 'V':
      finishCommand(result)
      kind = VLine
    of 'C':
      finishCommand(result)
      kind = Cubic
    of 'S':
      finishCommand(result)
      kind = SCubic
    of 'Q':
      finishCommand(result)
      kind = Quad
    of 'T':
      finishCommand(result)
      kind = TQuad
    of 'A':
      finishCommand(result)
      kind = Arc
    of 'Z':
      finishCommand(result)
      kind = Close
    of '-', '+':
      if numberStart > 0 and path[p - 1] in {'e', 'E'}:
        discard
      else:
        finishNumber()
        numberStart = p
    of '.':
      if hitDecimal or expectsArcFlag():
        finishNumber()
      hitDecimal = true
      if numberStart == 0:
        numberStart = p
    of ' ', ',', '\r', '\n', '\t':
      finishNumber()
    else:
      if numberStart > 0 and expectsArcFlag():
        finishNumber()
      if p - 1 == numberStart and path[p - 1] == '0':
        # If the number starts with 0 and we've hit another digit, finish the 0
        # .. 01.3.. -> [..0, 1.3..]
        finishNumber()
      if numberStart == 0:
        numberStart = p

    inc p

  finishCommand(result)

func transform*(path: Path, mat: Mat3) =
  if mat == mat3():
    return

  if path.commands.len > 0 and path.commands[0].kind == RMove:
    path.commands[0].kind = Move

  for command in path.commands.mitems:
    var mat = mat
    if command.kind.isRelative:
      mat.position = vec2()

    case command.kind:
    of Close:
      discard
    of Move, Line, RMove, RLine, TQuad, RTQuad:
      var position = vec2(command.numbers[0], command.numbers[1])
      position = mat * position
      command.numbers[0] = position.x
      command.numbers[1] = position.y
    of HLine, RHLine:
      var position = vec2(command.numbers[0], 0)
      position = mat * position
      command.numbers[0] = position.x
    of VLine, RVLine:
      var position = vec2(0, command.numbers[0])
      position = mat * position
      command.numbers[0] = position.y
    of Cubic, RCubic:
      var
        ctrl1 = vec2(command.numbers[0], command.numbers[1])
        ctrl2 = vec2(command.numbers[2], command.numbers[3])
        to = vec2(command.numbers[4], command.numbers[5])
      ctrl1 = mat * ctrl1
      ctrl2 = mat * ctrl2
      to = mat * to
      command.numbers[0] = ctrl1.x
      command.numbers[1] = ctrl1.y
      command.numbers[2] = ctrl2.x
      command.numbers[3] = ctrl2.y
      command.numbers[4] = to.x
      command.numbers[5] = to.y
    of SCubic, RSCubic, Quad, RQuad:
      var
        ctrl = vec2(command.numbers[0], command.numbers[1])
        to = vec2(command.numbers[2], command.numbers[3])
      ctrl = mat * ctrl
      to = mat * to
      command.numbers[0] = ctrl.x
      command.numbers[1] = ctrl.y
      command.numbers[2] = to.x
      command.numbers[3] = to.y
    of Arc, RArc:
      var
        radii = vec2(command.numbers[0], command.numbers[1])
        to = vec2(command.numbers[5], command.numbers[6])
      # Extract the scale from the matrix and only apply that to the radii
      radii = scale(vec2(mat[0][0], mat[1][1])) * radii
      to = mat * to
      command.numbers[0] = radii.x
      command.numbers[1] = radii.y
      command.numbers[5] = to.x
      command.numbers[6] = to.y

# func scale*(path)

# func closePath*(path: Path) =
#   path.commands.add(PathCommand(kind: Close))
#   path.at = path.start

# func moveTo*(path: Path, x, y: float) =
#   path.commands.add(PathCommand(kind: Move, numbers: @[x, y]))
#   path.start = (x, y)
#   path.at = path.start

# func moveTo*(path: Path, v: tuple[x, y: float]) {.inline.} =
#   path.moveTo(v.x, v.y)

# func lineTo*(path: Path, x, y: float) =
#   path.commands.add(PathCommand(kind: Line, numbers: @[x, y]))
#   path.at = (x, y)

# func lineTo*(path: Path, v: tuple[x, y: float]) {.inline.} =
#   path.lineTo(v.x, v.y)

# func bezierCurveTo*(path: Path, x1, y1, x2, y2, x3, y3: float) =
#   path.commands.add(PathCommand(
#     kind: Cubic,
#     numbers: @[x1, y1, x2, y2, x3, y3]
#   ))
#   path.at = (x3, y3)

# func bezierCurveTo*(path: Path, ctrl1, ctrl2, to: tuple[x, y: float]) =
#   path.bezierCurveTo(ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, to.x, to.y)

# func quadraticCurveTo*(path: Path, x1, y1, x2, y2: float) =
#   path.commands.add(PathCommand(
#     kind: Quad,
#     numbers: @[x1, y1, x2, y2]
#   ))
#   path.at = (x2, y2)

# func quadraticCurveTo*(path: Path, ctrl, to: tuple[x, y: float]) =
#   path.quadraticCurveTo(ctrl.x, ctrl.y, to.x, to.y)