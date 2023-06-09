{.experimental: "overloadableEnums".}

import std/hashes
import std/tables
import std/options
import ./math

const themeItemSize = vec2(50, 50)
const themeSpacing = 5.0
const themePadding = 5.0

type
  GuiId* = Hash

  GuiRetainedState* = ref object of RootObj
    init*: bool

  GuiContainer* = ref object of GuiRetainedState
    rect*: Rect2
    body*: Rect2
    contentSize*: Vec2
    scroll*: Vec2
    zIndex*: int
    isOpen*: bool

  GuiPositioning* = enum
    Relative
    Absolute

  GuiFreelyPositionedRect* = object
    positioning*: GuiPositioning
    rect*: Rect2

  GuiLayout* = object
    body*: Rect2
    max*: Vec2
    nextPosition*: Vec2
    rowSize*: Vec2
    widths*: seq[float]
    indexInRow*: int
    nextRow*: float
    indent*: float
    freelyPositionedRect*: Option[GuiFreelyPositionedRect]

  Gui* = ref object
    retainedState*: Table[GuiId, GuiRetainedState]
    idStack*: seq[GuiId]
    layoutStack*: seq[GuiLayout]
    containerStack*: seq[GuiContainer]
    lastRect*: Rect2
    lastZIndex*: int

proc getId*(gui: Gui, x: auto): GuiId =
  when x is GuiId:
    x
  else:
    if gui.idStack.len > 0:
      !$(gui.idStack[^1] !& hash(x))
    else:
      hash(x)

proc pushId*(gui: Gui, x: auto): GuiId {.discardable.} =
  when x is GuiId:
    result = x
  else:
    result = gui.getId(x)
  gui.idStack.add(result)

proc popId*(gui: Gui) =
  discard gui.idStack.pop()

proc currentLayout(gui: Gui): ptr GuiLayout =
  addr(gui.layoutStack[gui.layoutStack.len - 1])

proc newRow(gui: Gui, height: float) =
  let layout = gui.currentLayout
  layout.nextPosition.x = layout.indent
  layout.nextPosition.y = layout.nextRow
  layout.rowSize.y = height
  layout.indexInRow = 0

proc row*(gui: Gui, widths: openArray[float], height: float) =
  let layout = gui.currentLayout
  layout.widths.setLen(widths.len)
  for i in 0 ..< widths.len:
    layout.widths[i] = widths[i]
  gui.newRow(height)

proc nextRect*(gui: Gui): Rect2 =
  let layout = gui.currentLayout

  if layout.freelyPositionedRect.isSome:
    let freelyPositionedRect = layout.freelyPositionedRect.get
    layout.freelyPositionedRect = none(GuiFreelyPositionedRect)

    result = freelyPositionedRect.rect

    if freelyPositionedRect.positioning == Relative:
      result.x += layout.body.x
      result.y += layout.body.y

  else:
    if layout.indexInRow == layout.widths.len:
      gui.newRow(layout.rowSize.y)

    result.position = layout.nextPosition

    result.width =
      if layout.widths.len > 0:
        layout.widths[layout.indexInRow]
      else:
        layout.rowSize.x

    result.height = layout.rowSize.y

    if result.width == 0:
      result.width = themeItemSize.x

    if result.height == 0:
      result.height = themeItemSize.y

    if result.width < 0:
      result.width += layout.body.width - result.x + 1

    if result.height < 0:
      result.height += layout.body.height - result.y + 1

    layout.indexInRow += 1

    layout.nextPosition.x += result.width + themeSpacing
    layout.nextRow = max(layout.nextRow, result.y + result.height + themeSpacing)

    result.x += layout.body.x
    result.y += layout.body.y

  layout.max.x = max(layout.max.x, result.x + result.width)
  layout.max.y = max(layout.max.y, result.y + result.height)

  gui.lastRect = result

proc pushLayout*(gui: Gui, body: Rect2, scroll: Vec2) =
  gui.layoutStack.add GuiLayout(
    body: rect2(
      body.x - scroll.x, body.y - scroll.y,
      body.width, body.height,
    ),
    max: vec2(low(float), low(float)),
  )
  gui.row([0.0], 0.0)

proc popLayout*(gui: Gui) =
  discard gui.layoutStack.pop()

proc beginColumn*(gui: Gui) =
  gui.pushLayout(gui.nextRect, vec2(0, 0))

proc endColumn*(gui: Gui) =
  let b = gui.layoutStack.pop()
  let a = gui.currentLayout
  a.rowSize.x = max(a.rowSize.x, b.rowSize.x + b.body.x - a.body.x)
  a.nextRow = max(a.nextRow, b.nextRow + b.body.y - a.body.y)
  a.max.x = max(a.max.x, b.max.x)
  a.max.y = max(a.max.y, b.max.y)

template column*(gui: Gui, code: untyped): untyped =
  gui.beginColumn()
  code
  gui.endColumn()

proc setNextRect*(gui: Gui, rect: Rect2, positioning: GuiPositioning) =
  gui.currentLayout.freelyPositionedRect = some(GuiFreelyPositionedRect(
    positioning: positioning,
    rect: rect,
  ))

proc bringToFront*(gui: Gui, container: GuiContainer) =
  gui.lastZIndex += 1
  container.zIndex = gui.lastZIndex

proc getRetainedState*(gui: Gui, id: GuiId, T: typedesc): T =
  if gui.retainedState.hasKey(id):
    result = T(gui.retainedState[id])
    result.init = false
  else:
    result = T()
    result.init = true

proc currentContainer*(gui: Gui): GuiContainer =
  gui.containerStack[gui.containerStack.len - 1]

proc beginContainer*(gui: Gui, id: GuiId, rect: Rect2): bool =
  let container = gui.getRetainedState(id, GuiContainer)
  if not container.isOpen:
    return false
  container.rect = rect
  gui.pushId(id)
  gui.containerStack.add(container)

proc endContainer*(gui: Gui) =
  discard gui.containerStack.pop()
  gui.popId()

proc beginContainerBody*(gui: Gui, body: Rect2) =
  let container = gui.currentContainer
  container.body = body
  gui.pushLayout(body.expand(-themePadding), container.scroll)

proc endContainerBody*(gui: Gui) =
  let container = gui.currentContainer
  let layout = gui.currentLayout
  container.contentSize.x = layout.max.x - layout.body.x
  container.contentSize.y = layout.max.y - layout.body.y
  gui.popLayout()