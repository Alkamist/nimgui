import std/options
import ./math

type
  GuiLayout* = object
    itemSpacing*: Vec2
    defaultItemSize*: Vec2
    bounds*: Rect2
    max*: Vec2
    nextPosition*: Vec2
    rowSize*: Vec2
    widths*: seq[float]
    indexInRow*: int
    nextRow*: float
    indent*: float
    freeBounds*: Option[Rect2]

proc newRow(layout: var GuiLayout, height: float) =
  layout.nextPosition.x = layout.indent
  layout.nextPosition.y = layout.nextRow
  layout.rowSize.y = height
  layout.indexInRow = 0

proc row*(layout: var GuiLayout, widths: openArray[float], height: float) =
  layout.widths.setLen(widths.len)
  for i in 0 ..< widths.len:
    layout.widths[i] = widths[i]
  layout.newRow(height)

proc getNextBounds*(layout: var GuiLayout): Rect2 =
  if layout.freeBounds.isSome:
    result = layout.freeBounds.get
    layout.freeBounds = none(Rect2)

  else:
    if layout.indexInRow == layout.widths.len:
      layout.newRow(layout.rowSize.y)

    result.position = layout.nextPosition

    result.width =
      if layout.widths.len > 0:
        layout.widths[layout.indexInRow]
      else:
        layout.rowSize.x

    result.height = layout.rowSize.y

    if result.width == 0:
      result.width = layout.defaultItemSize.x

    if result.height == 0:
      result.height = layout.defaultItemSize.y

    if result.width < 0:
      result.width += layout.bounds.width - result.x + 1

    if result.height < 0:
      result.height += layout.bounds.height - result.y + 1

    layout.indexInRow += 1

    result.position += layout.bounds.position

    layout.nextPosition.x += result.width + layout.itemSpacing.x
    layout.nextRow = max(layout.nextRow, result.y + result.height + layout.itemSpacing.y)

  layout.max.x = max(layout.max.x, result.x + result.width)
  layout.max.y = max(layout.max.y, result.y + result.height)

proc `nextBounds=`*(layout: var GuiLayout, bounds: Rect2) =
  layout.freeBounds = some(bounds)