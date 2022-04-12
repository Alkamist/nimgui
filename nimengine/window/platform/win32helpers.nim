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
    MouseButton.Left
  of WM_MBUTTONDOWN, WM_MBUTTONUP, WM_MBUTTONDBLCLK:
    MouseButton.Middle
  of WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
    MouseButton.Right
  of WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK:
    if HIWORD(wParam) == 1:
      MouseButton.Extra1
    else:
      MouseButton.Extra2
  else:
    MouseButton.Unknown

func toKeyboardKey*(scanCode: int): KeyboardKey =
  case scanCode:
  of 8: KeyboardKey.Backspace
  of 9: KeyboardKey.Tab
  of 13: KeyboardKey.Enter
  of 19: KeyboardKey.Pause
  of 20: KeyboardKey.CapsLock
  of 27: KeyboardKey.Escape
  of 32: KeyboardKey.Space
  of 33: KeyboardKey.PageUp
  of 34: KeyboardKey.PageDown
  of 35: KeyboardKey.End
  of 36: KeyboardKey.Home
  of 37: KeyboardKey.LeftArrow
  of 38: KeyboardKey.UpArrow
  of 39: KeyboardKey.RightArrow
  of 40: KeyboardKey.DownArrow
  of 45: KeyboardKey.Insert
  of 46: KeyboardKey.Delete
  of 48: KeyboardKey.Key0
  of 49: KeyboardKey.Key1
  of 50: KeyboardKey.Key2
  of 51: KeyboardKey.Key3
  of 52: KeyboardKey.Key4
  of 53: KeyboardKey.Key5
  of 54: KeyboardKey.Key6
  of 55: KeyboardKey.Key7
  of 56: KeyboardKey.Key8
  of 57: KeyboardKey.Key9
  of 65: KeyboardKey.A
  of 66: KeyboardKey.B
  of 67: KeyboardKey.C
  of 68: KeyboardKey.D
  of 69: KeyboardKey.E
  of 70: KeyboardKey.F
  of 71: KeyboardKey.G
  of 72: KeyboardKey.H
  of 73: KeyboardKey.I
  of 74: KeyboardKey.J
  of 75: KeyboardKey.K
  of 76: KeyboardKey.L
  of 77: KeyboardKey.M
  of 78: KeyboardKey.N
  of 79: KeyboardKey.O
  of 80: KeyboardKey.P
  of 81: KeyboardKey.Q
  of 82: KeyboardKey.R
  of 83: KeyboardKey.S
  of 84: KeyboardKey.T
  of 85: KeyboardKey.U
  of 86: KeyboardKey.V
  of 87: KeyboardKey.W
  of 88: KeyboardKey.X
  of 89: KeyboardKey.Y
  of 90: KeyboardKey.Z
  of 91: KeyboardKey.LeftMeta
  of 92: KeyboardKey.RightMeta
  of 96: KeyboardKey.Pad0
  of 97: KeyboardKey.Pad1
  of 98: KeyboardKey.Pad2
  of 99: KeyboardKey.Pad3
  of 100: KeyboardKey.Pad4
  of 101: KeyboardKey.Pad5
  of 102: KeyboardKey.Pad6
  of 103: KeyboardKey.Pad7
  of 104: KeyboardKey.Pad8
  of 105: KeyboardKey.Pad9
  of 106: KeyboardKey.PadMultiply
  of 107: KeyboardKey.PadAdd
  of 109: KeyboardKey.PadSubtract
  of 110: KeyboardKey.PadPeriod
  of 111: KeyboardKey.PadDivide
  of 112: KeyboardKey.F1
  of 113: KeyboardKey.F2
  of 114: KeyboardKey.F3
  of 115: KeyboardKey.F4
  of 116: KeyboardKey.F5
  of 117: KeyboardKey.F6
  of 118: KeyboardKey.F7
  of 119: KeyboardKey.F8
  of 120: KeyboardKey.F9
  of 121: KeyboardKey.F10
  of 122: KeyboardKey.F11
  of 123: KeyboardKey.F12
  of 144: KeyboardKey.NumLock
  of 145: KeyboardKey.ScrollLock
  of 186: KeyboardKey.Semicolon
  of 187: KeyboardKey.Equal
  of 188: KeyboardKey.Comma
  of 189: KeyboardKey.Minus
  of 190: KeyboardKey.Period
  of 191: KeyboardKey.Slash
  of 192: KeyboardKey.Backtick
  of 219: KeyboardKey.LeftBracket
  of 220: KeyboardKey.BackSlash
  of 221: KeyboardKey.RightBracket
  of 222: KeyboardKey.Quote
  else: KeyboardKey.Unknown