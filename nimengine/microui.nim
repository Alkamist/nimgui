import std/strutils

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

{.compile: "microui.c", passC: "-Wall -c -O3".}

const microuiHeader = currentSourceDir() & "/microui.h"

const COMMANDLIST_SIZE* = 256 * 1024
const ROOTLIST_SIZE* = 32
const CONTAINERSTACK_SIZE* = 32
const CLIPSTACK_SIZE* = 32
const IDSTACK_SIZE* = 32
const LAYOUTSTACK_SIZE* = 16
const CONTAINERPOOL_SIZE* = 48
const TREENODEPOOL_SIZE* = 48
const MAX_WIDTHS* = 16
const REAL_FMT* = "%.3g"
const SLIDER_FMT* = "%.2f"
const MAX_FMT* = 127
const COMMAND_JUMP* = 1
const COMMAND_CLIP* = 2
const COMMAND_RECT* = 3
const COMMAND_TEXT* = 4
const COMMAND_ICON* = 5
const COMMAND_MAX* = 6
const COLOR_TEXT* = 0
const COLOR_BORDER* = 1
const COLOR_WINDOWBG* = 2
const COLOR_TITLEBG* = 3
const COLOR_TITLETEXT* = 4
const COLOR_PANELBG* = 5
const COLOR_BUTTON* = 6
const COLOR_BUTTONHOVER* = 7
const COLOR_BUTTONFOCUS* = 8
const COLOR_BASE* = 9
const COLOR_BASEHOVER* = 10
const COLOR_BASEFOCUS* = 11
const COLOR_SCROLLBASE* = 12
const COLOR_SCROLLTHUMB* = 13
const COLOR_MAX* = 14
const ICON_CLOSE* = 1
const ICON_CHECK* = 2
const ICON_COLLAPSED* = 3
const ICON_EXPANDED* = 4
const ICON_MAX* = 5
const RES_ACTIVE* = (1 shl 0)
const RES_SUBMIT* = (1 shl 1)
const RES_CHANGE* = (1 shl 2)
const OPT_ALIGNCENTER* = (1 shl 0)
const OPT_ALIGNRIGHT* = (1 shl 1)
const OPT_NOINTERACT* = (1 shl 2)
const OPT_NOFRAME* = (1 shl 3)
const OPT_NORESIZE* = (1 shl 4)
const OPT_NOSCROLL* = (1 shl 5)
const OPT_NOCLOSE* = (1 shl 6)
const OPT_NOTITLE* = (1 shl 7)
const OPT_HOLDFOCUS* = (1 shl 8)
const OPT_AUTOSIZE* = (1 shl 9)
const OPT_POPUP* = (1 shl 10)
const OPT_CLOSED* = (1 shl 11)
const OPT_EXPANDED* = (1 shl 12)
const MOUSE_LEFT* = (1 shl 0)
const MOUSE_RIGHT* = (1 shl 1)
const MOUSE_MIDDLE* = (1 shl 2)
const KEY_SHIFT* = (1 shl 0)
const KEY_CTRL* = (1 shl 1)
const KEY_ALT* = (1 shl 2)
const KEY_BACKSPACE* = (1 shl 3)
const KEY_RETURN* = (1 shl 4)

template Stack*(T: typedesc, n: int): untyped =
  tuple[idx: int, items: array[n, T]]

type
  Id* {.importc: "mu_Id", header: microuiHeader.} = cuint
  Real* {.importc: "mu_Real", header: microuiHeader.} = cfloat
  Font* {.importc: "mu_Font", header: microuiHeader.} = pointer
  Vec2* {.importc: "mu_Vec2", header: microuiHeader.} = object
    x*: cint
    y*: cint

  Rect* {.importc: "mu_Rect", header: microuiHeader.} = object
    x*: cint
    y*: cint
    w*: cint
    h*: cint

  Color* {.importc: "mu_Color", header: microuiHeader.} = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

  PoolItem* {.importc: "mu_PoolItem", header: microuiHeader.} = object
    id*: Id
    last_update*: cint

  BaseCommand* {.importc: "mu_BaseCommand", header: microuiHeader.} = object
    `type`*: cint
    size*: cint

  JumpCommand* {.importc: "mu_JumpCommand", header: microuiHeader.} = object
    base*: BaseCommand
    dst*: pointer

  ClipCommand* {.importc: "mu_ClipCommand", header: microuiHeader.} = object
    base*: BaseCommand
    rect*: Rect

  RectCommand* {.importc: "mu_RectCommand", header: microuiHeader.} = object
    base*: BaseCommand
    rect*: Rect
    color*: Color

  TextCommand* {.importc: "mu_TextCommand", header: microuiHeader.} = object
    base*: BaseCommand
    font*: Font
    pos*: Vec2
    color*: Color
    str*: array[1, char]

  IconCommand* {.importc: "mu_IconCommand", header: microuiHeader.} = object
    base*: BaseCommand
    rect*: Rect
    id*: cint
    color*: Color

  Command* {.importc: "mu_Command", header: microuiHeader, union.} = object
    `type`*: cint
    base*: BaseCommand
    jump*: JumpCommand
    clip*: ClipCommand
    rect*: RectCommand
    text*: TextCommand
    icon*: IconCommand

  Layout* {.importc: "mu_Layout", header: microuiHeader.} = object
    body*: Rect
    next*: Rect
    position*: Vec2
    size*: Vec2
    max*: Vec2
    widths*: array[MAX_WIDTHS, cint]
    items*: cint
    item_index*: cint
    next_row*: cint
    next_type*: cint
    indent*: cint

  Container* {.importc: "mu_Container", header: microuiHeader.} = object
    head*: ptr Command
    tail*: ptr Command
    rect*: Rect
    body*: Rect
    content_size*: Vec2
    scroll*: Vec2
    zindex*: cint
    open*: cint

  Style* {.importc: "mu_Style", header: microuiHeader.} = object
    font*: Font
    size*: Vec2
    padding*: cint
    spacing*: cint
    indent*: cint
    title_height*: cint
    scrollbar_size*: cint
    thumb_size*: cint
    colors*: array[COLOR_MAX, Color]

  Context* {.importc: "mu_Context", header: microuiHeader.} = object
    text_width*: proc (font: Font, str: cstring, len: cint): cint {.cdecl.}
    text_height*: proc (font: Font): cint {.cdecl.}
    draw_frame*: proc (ctx: ptr Context, rect: Rect, colorid: cint) {.cdecl.} ##  core state
    ustyle* {.importc: "_style".}: Style
    style*: ptr Style
    hover*: Id
    focus*: Id
    last_id*: Id
    last_rect*: Rect
    last_zindex*: cint
    updated_focus*: cint
    frame*: cint
    hover_root*: ptr Container
    next_hover_root*: ptr Container
    scroll_target*: ptr Container
    number_edit_buf*: array[MAX_FMT, char]
    number_edit*: Id
    command_list*: Stack(char, COMMANDLIST_SIZE)
    root_list*: Stack(ptr Container, ROOTLIST_SIZE)
    container_stack*: Stack(ptr Container, CONTAINERPOOL_SIZE)
    clip_stack*: Stack(Rect, CLIPSTACK_SIZE)
    id_stack*: Stack(Id, IDSTACK_SIZE)
    layout_stack*: Stack(Layout, LAYOUTSTACK_SIZE)
    container_pool*: array[CONTAINERPOOL_SIZE, PoolItem]
    containers*: array[CONTAINERPOOL_SIZE, Container]
    treenode_pool*: array[TREENODEPOOL_SIZE, PoolItem]
    mouse_pos*: Vec2
    last_mouse_pos*: Vec2
    mouse_delta*: Vec2
    scroll_delta*: Vec2
    mouse_down*: cint
    mouse_pressed*: cint
    key_down*: cint
    key_pressed*: cint
    input_text*: array[32, char]

proc vec2*(x, y: cint): Vec2 {.importc: "mu_vec2", header: microuiHeader.}
proc rect*(x, y, w, h: cint): Rect {.importc: "mu_rect", header: microuiHeader.}
proc color*(r, g, b, a: cint): Color {.importc: "mu_color", header: microuiHeader.}
proc init*(ctx: ptr Context) {.importc: "mu_init", header: microuiHeader.}
proc begin*(ctx: ptr Context) {.importc: "mu_begin", header: microuiHeader.}
proc `end`*(ctx: ptr Context) {.importc: "mu_end", header: microuiHeader.}
proc set_focus*(ctx: ptr Context, id: Id) {.importc: "mu_set_focus", header: microuiHeader.}
proc get_id*(ctx: ptr Context, data: pointer, size: cint): Id {.importc: "mu_get_id", header: microuiHeader.}
proc push_id*(ctx: ptr Context, data: pointer, size: cint) {.importc: "mu_push_id", header: microuiHeader.}
proc pop_id*(ctx: ptr Context) {.importc: "mu_pop_id", header: microuiHeader.}
proc push_clip_rect*(ctx: ptr Context, rect: Rect) {.importc: "mu_push_clip_rect", header: microuiHeader.}
proc pop_clip_rect*(ctx: ptr Context) {.importc: "mu_pop_clip_rect", header: microuiHeader.}
proc get_clip_rect*(ctx: ptr Context): Rect {.importc: "mu_get_clip_rect", header: microuiHeader.}
proc check_clip*(ctx: ptr Context, r: Rect): cint {.importc: "mu_check_clip", header: microuiHeader.}
proc get_current_container*(ctx: ptr Context): ptr Container {.importc: "mu_get_current_container", header: microuiHeader.}
proc get_container*(ctx: ptr Context, name: cstring): ptr Container {.importc: "mu_get_container", header: microuiHeader.}
proc bring_to_front*(ctx: ptr Context, cnt: ptr Container) {.importc: "mu_bring_to_front", header: microuiHeader.}
proc pool_init*(ctx: ptr Context, items: ptr PoolItem, len: cint, id: Id): cint {.importc: "mu_pool_init", header: microuiHeader.}
proc pool_get*(ctx: ptr Context, items: ptr PoolItem, len: cint, id: Id): cint {.importc: "mu_pool_get", header: microuiHeader.}
proc pool_update*(ctx: ptr Context, items: ptr PoolItem, idx: cint) {.importc: "mu_pool_update", header: microuiHeader.}
proc input_mousemove*(ctx: ptr Context, x, y: cint) {.importc: "mu_input_mousemove", header: microuiHeader.}
proc input_mousedown*(ctx: ptr Context, x, y, btn: cint) {.importc: "mu_input_mousedown", header: microuiHeader.}
proc input_mouseup*(ctx: ptr Context, x, y, btn: cint) {.importc: "mu_input_mouseup", header: microuiHeader.}
proc input_scroll*(ctx: ptr Context, x, y: cint) {.importc: "mu_input_scroll", header: microuiHeader.}
proc input_keydown*(ctx: ptr Context, key: cint) {.importc: "mu_input_keydown", header: microuiHeader.}
proc input_keyup*(ctx: ptr Context, key: cint) {.importc: "mu_input_keyup", header: microuiHeader.}
proc input_text*(ctx: ptr Context, text: cstring) {.importc: "mu_input_text", header: microuiHeader.}
proc push_command*(ctx: ptr Context, `type`, size: cint): ptr Command {.importc: "mu_push_command", header: microuiHeader.}
proc next_command*(ctx: ptr Context, cmd: ptr ptr Command): cint {.importc: "mu_next_command", header: microuiHeader.}
proc set_clip*(ctx: ptr Context, rect: Rect) {.importc: "mu_set_clip", header: microuiHeader.}
proc draw_rect*(ctx: ptr Context, rect: Rect, color: Color) {.importc: "mu_draw_rect", header: microuiHeader.}
proc draw_box*(ctx: ptr Context, rect: Rect, color: Color) {.importc: "mu_draw_box", header: microuiHeader.}
proc draw_text*(ctx: ptr Context, font: Font, str: cstring, len: cint, pos: Vec2, color: Color) {.importc: "mu_draw_text", header: microuiHeader.}
proc draw_icon*(ctx: ptr Context, id: cint, rect: Rect, color: Color) {.importc: "mu_draw_icon", header: microuiHeader.}
proc layout_row*(ctx: ptr Context, items: cint, widths: ptr cint, height: cint) {.importc: "mu_layout_row", header: microuiHeader.}
proc layout_width*(ctx: ptr Context, width: cint) {.importc: "mu_layout_width", header: microuiHeader.}
proc layout_height*(ctx: ptr Context, height: cint) {.importc: "mu_layout_height", header: microuiHeader.}
proc layout_begin_column*(ctx: ptr Context) {.importc: "mu_layout_begin_column", header: microuiHeader.}
proc layout_end_column*(ctx: ptr Context) {.importc: "mu_layout_end_column", header: microuiHeader.}
proc layout_set_next*(ctx: ptr Context, r: Rect, relative: cint) {.importc: "mu_layout_set_next", header: microuiHeader.}
proc layout_next*(ctx: ptr Context): Rect {.importc: "mu_layout_next", header: microuiHeader.}
proc draw_control_frame*(ctx: ptr Context, id: Id, rect: Rect, colorid, opt: cint) {.importc: "mu_draw_control_frame", header: microuiHeader.}
proc draw_control_text*(ctx: ptr Context, str: cstring, rect: Rect, colorid, opt: cint) {.importc: "mu_draw_control_text", header: microuiHeader.}
proc mouse_over*(ctx: ptr Context, rect: Rect): cint {.importc: "mu_mouse_over", header: microuiHeader.}
proc update_control*(ctx: ptr Context, id: Id, rect: Rect, opt: cint) {.importc: "mu_update_control", header: microuiHeader.}
proc text*(ctx: ptr Context, text: cstring) {.importc: "mu_text", header: microuiHeader.}
proc label*(ctx: ptr Context, text: cstring) {.importc: "mu_label", header: microuiHeader.}
proc button_ex*(ctx: ptr Context, label: cstring, icon, opt: cint): cint {.importc: "mu_button_ex", header: microuiHeader.}
proc checkbox*(ctx: ptr Context, label: cstring, state: ptr cint): cint {.importc: "mu_checkbox", header: microuiHeader.}
proc textbox_raw*(ctx: ptr Context, buf: cstring, bufsz: cint, id: Id, r: Rect, opt: cint): cint {.importc: "mu_textbox_raw", header: microuiHeader.}
proc textbox_ex*(ctx: ptr Context, buf: cstring, bufsz, opt: cint): cint {.importc: "mu_textbox_ex", header: microuiHeader.}
proc slider_ex*(ctx: ptr Context, value: ptr Real, `low`: Real, `high`: Real, step: Real, fmt: cstring, opt: cint): cint {.importc: "mu_slider_ex", header: microuiHeader.}
proc number_ex*(ctx: ptr Context, value: ptr Real, step: Real, fmt: cstring, opt: cint): cint {.importc: "mu_number_ex", header: microuiHeader.}
proc header_ex*(ctx: ptr Context, label: cstring, opt: cint): cint {.importc: "mu_header_ex", header: microuiHeader.}
proc begin_treenode_ex*(ctx: ptr Context, label: cstring, opt: cint): cint {.importc: "mu_begin_treenode_ex", header: microuiHeader.}
proc end_treenode*(ctx: ptr Context) {.importc: "mu_end_treenode", header: microuiHeader.}
proc begin_window_ex*(ctx: ptr Context, title: cstring, rect: Rect, opt: cint): cint {.importc: "mu_begin_window_ex", header: microuiHeader.}
proc end_window*(ctx: ptr Context) {.importc: "mu_end_window", header: microuiHeader.}
proc open_popup*(ctx: ptr Context, name: cstring) {.importc: "mu_open_popup", header: microuiHeader.}
proc begin_popup*(ctx: ptr Context, name: cstring): cint {.importc: "mu_begin_popup", header: microuiHeader.}
proc end_popup*(ctx: ptr Context) {.importc: "mu_end_popup", header: microuiHeader.}
proc begin_panel_ex*(ctx: ptr Context, name: cstring, opt: cint) {.importc: "mu_begin_panel_ex", header: microuiHeader.}
proc end_panel*(ctx: ptr Context) {.importc: "mu_end_panel", header: microuiHeader.}

proc button*(ctx: ptr Context, label: cstring): cint = button_ex(ctx, label, 0, OPT_ALIGNCENTER)
proc textbox*(ctx: ptr Context, buf: cstring, bufsz: cint): cint = textbox_ex(ctx, buf, bufsz, 0)
proc slider*(ctx: ptr Context, value: ptr Real, `low`: Real, `high`: Real): cint = slider_ex(ctx, value, `low`, `high`, 0, SLIDER_FMT, OPT_ALIGNCENTER)
proc number*(ctx: ptr Context, value: ptr Real, step: Real): cint = number_ex(ctx, value, step, SLIDER_FMT, OPT_ALIGNCENTER)
proc header*(ctx: ptr Context, label: cstring): cint = header_ex(ctx, label, 0)
proc begin_treenode*(ctx: ptr Context, label: cstring): cint = begin_treenode_ex(ctx, label, 0)
proc begin_window*(ctx: ptr Context, title: cstring, rect: Rect): cint = begin_window_ex(ctx, title, rect, 0)
proc begin_panel*(ctx: ptr Context, name: cstring) = begin_panel_ex(ctx, name, 0)