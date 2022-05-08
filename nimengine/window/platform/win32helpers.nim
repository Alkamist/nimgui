{.experimental: "overloadableEnums".}

import std/options
import winim/lean as win32
import ../types

export options

func getClientWidthAndHeight*(hwnd: HWND): (LONG, LONG) =
  var area: win32.RECT
  GetClientRect(hwnd, area.addr)
  (area.right, area.bottom)

func getCursorPosition*(hwnd: HWND): Option[(LONG, LONG)] =
  var pos: POINT
  if GetCursorPos(pos.addr):
    ScreenToClient(hwnd, pos.addr)
    return some (pos.x, pos.y)

proc setClipRectToWindow*(hwnd: HWND) =
  var clipRect: win32.RECT
  GetClientRect(hwnd, &clipRect)
  ClientToScreen(hwnd, cast[ptr POINT](clipRect.left.addr))
  ClientToScreen(hwnd, cast[ptr POINT](clipRect.right.addr))
  ClipCursor(&clipRect)

proc removeClipRect*() =
  ClipCursor(nil)

proc pollEvents*(hwnd: HWND) =
  var msg: MSG
  while PeekMessage(msg, hwnd, 0, 0, PM_REMOVE) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)

func toMouseButton*(msg: UINT, wParam: WPARAM): MouseButton =
  case msg:
  of WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK:
    Left
  of WM_MBUTTONDOWN, WM_MBUTTONUP, WM_MBUTTONDBLCLK:
    Middle
  of WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
    Right
  of WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK:
    if HIWORD(wParam) == 1:
      Extra1
    else:
      Extra2
  else:
    Unknown

func toKeyboardKey*(scanCode: int): KeyboardKey =
  case scanCode:
  of 8: Backspace
  of 9: Tab
  of 13: Enter
  of 19: Pause
  of 20: CapsLock
  of 27: Escape
  of 32: Space
  of 33: PageUp
  of 34: PageDown
  of 35: End
  of 36: Home
  of 37: LeftArrow
  of 38: UpArrow
  of 39: RightArrow
  of 40: DownArrow
  of 45: Insert
  of 46: KeyboardKey.Delete
  of 48: Key0
  of 49: Key1
  of 50: Key2
  of 51: Key3
  of 52: Key4
  of 53: Key5
  of 54: Key6
  of 55: Key7
  of 56: Key8
  of 57: Key9
  of 65: A
  of 66: B
  of 67: C
  of 68: D
  of 69: E
  of 70: F
  of 71: G
  of 72: H
  of 73: I
  of 74: J
  of 75: K
  of 76: L
  of 77: M
  of 78: N
  of 79: O
  of 80: P
  of 81: Q
  of 82: R
  of 83: S
  of 84: T
  of 85: U
  of 86: V
  of 87: W
  of 88: X
  of 89: Y
  of 90: Z
  of 91: LeftMeta
  of 92: RightMeta
  of 96: Pad0
  of 97: Pad1
  of 98: Pad2
  of 99: Pad3
  of 100: Pad4
  of 101: Pad5
  of 102: Pad6
  of 103: Pad7
  of 104: Pad8
  of 105: Pad9
  of 106: PadMultiply
  of 107: PadAdd
  of 109: PadSubtract
  of 110: PadPeriod
  of 111: PadDivide
  of 112: F1
  of 113: F2
  of 114: F3
  of 115: F4
  of 116: F5
  of 117: F6
  of 118: F7
  of 119: F8
  of 120: F9
  of 121: F10
  of 122: F11
  of 123: F12
  of 144: NumLock
  of 145: ScrollLock
  of 186: Semicolon
  of 187: Equal
  of 188: Comma
  of 189: Minus
  of 190: Period
  of 191: Slash
  of 192: Backtick
  of 219: LeftBracket
  of 220: BackSlash
  of 221: RightBracket
  of 222: Quote
  else: Unknown