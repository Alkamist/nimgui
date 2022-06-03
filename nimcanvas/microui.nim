{.experimental: "overloadableEnums".}

import ./tmath

const commandListSize* = 256 * 1024
const rootListSize* = 32
const containerStackSize* = 32
const clipStackSize* = 32
const idStackSize* = 32
const layoutStackSize* = 16
const containerPoolSize* = 48
const treeNodePoolSize* = 48
const maxWidths* = 16
const maxFmt* = 127

type
  Id* = uint

  Stack*[N, T] = object
    writeIndex*: int
    items*: array[N, T]

  PoolItem* = object
    id*: Id
    lastUpdate*: int

  ColorKind* = enum
    Text
    Border
    Windowbg
    Titlebg
    Titletext
    Panelbg
    Button
    Buttonhover
    Buttonfocus
    Base
    Basehover
    Basefocus
    Scrollbase
    Scrollthumb

  Font* = pointer

  CommandKind* = enum
    Jump
    Clip
    Rect
    Text
    Icon

  JumpCommand* = object
    destination*: pointer

  ClipCommand* = object
    rect*: Rect2

  RectCommand* = object
    rect*: Rect2
    color*: Color

  TextCommand* = object
    font*: Font
    position*: Vec2
    color*: Color
    text*: char

  IconCommand* = object
    rect*: Rect2
    id*: int
    color*: Color

  Command* = object
    size*: int
    case kind*: CommandKind
    of Jump: jump*: JumpCommand
    of Clip: clip*: ClipCommand
    of Rect: rect*: RectCommand
    of Text: text*: TextCommand
    of Icon: icon*: IconCommand

  Layout* = object
    body*: Rect2
    next*: Rect2
    position*: Vec2
    size*: Vec2
    max*: Vec2
    widths: array[maxWidths, int]
    items*: int
    itemIndex*: int
    nextRow*: int
    nextType*: int
    indent*: int

  Container* = object
    head*, tail*: ptr Command
    rect*: Rect2
    body*: Rect2
    contentSize*: Vec2
    scroll*: Vec2
    zindex*: int
    open*: int

  Style* = object
    font*: Font
    size*: Vec2
    padding*: int
    spacing*: int
    indent*: int
    titleHeight*: int
    scrollbarSize*: int
    thumbSize*: int
    colors*: array[ColorKind, Color]

  Context* = object
    # Callbacks.
    textWidth*: proc(font: Font, text: string): int
    textHeight*: proc(font: Font): int
    drawFrame*: proc(ctx: Context, rect: Rect2, colorKind: ColorKind)

    # Core state.
    style*: Style
    hover*: Id
    focus*: Id
    lastId*: Id
    lastRect*: Rect2
    lastZIndex*: int
    updatedFocus*: int
    frame*: int
    hoverRoot*: ptr Container
    nextHoverRoot*: ptr Container
    scrollTarget*: ptr Container
    numberEditBuf*: array[maxFmt, char]
    numberEdit: Id

    # Stacks.
    commandList*: Stack[commandListSize, char]
    rootList*: Stack[rootListSize, ptr Container]
    containerStack*: Stack[containerStackSize, ptr Container]
    clipStack*: Stack[clipStackSize, Rect2]
    idStack*: Stack[idStackSize, Id]
    layoutStack*: Stack[layoutStackSize, Layout]

    # Retained state pools.
    containerPool*: array[containerPoolSize, PoolItem]
    containers*: array[containerPoolSize, Container]
    treenodePool*: array[treeNodePoolSize, PoolItem]

    # Input state.
    mousePosition*: Vec2
    lastMousePosition*: Vec2
    mouseDelta*: Vec2
    scrollDelta*: Vec2
    mouseDown*: int
    mousePressed*: int
    keyDown*: int
    keyPressed*: int
    inputText*: array[32, char]

# ============================================================================
#  commandlist
# ============================================================================

proc pushCommand(ctx: ptr Context, kind: CommandKind, size: int): ptr Command =
  var cmd = cast[ptr Command](ctx.commandList.items[ctx.commandList.writeIndex].addr)
  assert(ctx.commandList.writeIndex + size < commandListSize)
  cmd.kind = kind
  cmd.size = size
  ctx.commandList.writeIndex += size
  return cmd

int mu_next_command(mu_Context *ctx, mu_Command **cmd) {
  if (*cmd) {
    *cmd = (mu_Command*) (((char*) *cmd) + (*cmd)->base.size);
  } else {
    *cmd = (mu_Command*) ctx->command_list.items;
  }
  while ((char*) *cmd != ctx->command_list.items + ctx->command_list.idx) {
    if ((*cmd)->type != MU_COMMAND_JUMP) { return 1; }
    *cmd = (*cmd)->jump.dst;
  }
  return 0;
}