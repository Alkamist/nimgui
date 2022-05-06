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
    left
  of WM_MBUTTONDOWN, WM_MBUTTONUP, WM_MBUTTONDBLCLK:
    middle
  of WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK:
    right
  of WM_XBUTTONDOWN, WM_XBUTTONUP, WM_XBUTTONDBLCLK:
    if HIWORD(wParam) == 1:
      extra1
    else:
      extra2
  else:
    unknown

func toKeyboardKey*(scanCode: int): KeyboardKey =
  case scanCode:
  of 8: backspace
  of 9: tab
  of 13: enter
  of 19: pause
  of 20: capsLock
  of 27: escape
  of 32: space
  of 33: pageUp
  of 34: pageDown
  of 35: keyEnd
  of 36: home
  of 37: leftArrow
  of 38: upArrow
  of 39: rightArrow
  of 40: downArrow
  of 45: insert
  of 46: delete
  of 48: key0
  of 49: key1
  of 50: key2
  of 51: key3
  of 52: key4
  of 53: key5
  of 54: key6
  of 55: key7
  of 56: key8
  of 57: key9
  of 65: a
  of 66: b
  of 67: c
  of 68: d
  of 69: e
  of 70: f
  of 71: g
  of 72: h
  of 73: i
  of 74: j
  of 75: k
  of 76: l
  of 77: m
  of 78: n
  of 79: o
  of 80: p
  of 81: q
  of 82: r
  of 83: s
  of 84: t
  of 85: u
  of 86: v
  of 87: w
  of 88: x
  of 89: y
  of 90: z
  of 91: leftMeta
  of 92: rightMeta
  of 96: pad0
  of 97: pad1
  of 98: pad2
  of 99: pad3
  of 100: pad4
  of 101: pad5
  of 102: pad6
  of 103: pad7
  of 104: pad8
  of 105: pad9
  of 106: padMultiply
  of 107: padAdd
  of 109: padSubtract
  of 110: padPeriod
  of 111: padDivide
  of 112: f1
  of 113: f2
  of 114: f3
  of 115: f4
  of 116: f5
  of 117: f6
  of 118: f7
  of 119: f8
  of 120: f9
  of 121: f10
  of 122: f11
  of 123: f12
  of 144: numLock
  of 145: scrollLock
  of 186: semicolon
  of 187: equal
  of 188: comma
  of 189: minus
  of 190: period
  of 191: slash
  of 192: backtick
  of 219: leftBracket
  of 220: backSlash
  of 221: rightBracket
  of 222: quote
  else: unknown