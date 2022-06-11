{.experimental: "overloadableEnums".}

import std/tables
import std/sequtils
import winim/lean except INPUT
import ./uihandler; export uihandler

var osUi* = UiHandler()
osUi.init()

proc toBiTable[K, V](entries: openArray[(K, V)]): (Table[K, V], Table[V, K]) =
  let reverseEntries = entries.mapIt((it[1], it[0]))
  result = (entries.toTable(), reverseEntries.toTable())

const (toKeyCode, toKeyboardKey) = {
  KeyboardKey.Backspace: 8,
  KeyboardKey.Tab: 9,
  KeyboardKey.Pause: 19,
  KeyboardKey.CapsLock: 20,
  KeyboardKey.Escape: 27,
  KeyboardKey.Space: 32,
  KeyboardKey.PageUp: 33,
  KeyboardKey.PageDown: 34,
  KeyboardKey.End: 35,
  KeyboardKey.Home: 36,
  KeyboardKey.LeftArrow: 37,
  KeyboardKey.UpArrow: 38,
  KeyboardKey.RightArrow: 39,
  KeyboardKey.DownArrow: 40,
  KeyboardKey.PrintScreen: 44,
  KeyboardKey.Insert: 45,
  KeyboardKey.Delete: 46,
  KeyboardKey.Key0: 48,
  KeyboardKey.Key1: 49,
  KeyboardKey.Key2: 50,
  KeyboardKey.Key3: 51,
  KeyboardKey.Key4: 52,
  KeyboardKey.Key5: 53,
  KeyboardKey.Key6: 54,
  KeyboardKey.Key7: 55,
  KeyboardKey.Key8: 56,
  KeyboardKey.Key9: 57,
  KeyboardKey.A: 65,
  KeyboardKey.B: 66,
  KeyboardKey.C: 67,
  KeyboardKey.D: 68,
  KeyboardKey.E: 69,
  KeyboardKey.F: 70,
  KeyboardKey.G: 71,
  KeyboardKey.H: 72,
  KeyboardKey.I: 73,
  KeyboardKey.J: 74,
  KeyboardKey.K: 75,
  KeyboardKey.L: 76,
  KeyboardKey.M: 77,
  KeyboardKey.N: 78,
  KeyboardKey.O: 79,
  KeyboardKey.P: 80,
  KeyboardKey.Q: 81,
  KeyboardKey.R: 82,
  KeyboardKey.S: 83,
  KeyboardKey.T: 84,
  KeyboardKey.U: 85,
  KeyboardKey.V: 86,
  KeyboardKey.W: 87,
  KeyboardKey.X: 88,
  KeyboardKey.Y: 89,
  KeyboardKey.Z: 90,
  KeyboardKey.LeftMeta: 91,
  KeyboardKey.RightMeta: 92,
  KeyboardKey.Pad0: 96,
  KeyboardKey.Pad1: 97,
  KeyboardKey.Pad2: 98,
  KeyboardKey.Pad3: 99,
  KeyboardKey.Pad4: 100,
  KeyboardKey.Pad5: 101,
  KeyboardKey.Pad6: 102,
  KeyboardKey.Pad7: 103,
  KeyboardKey.Pad8: 104,
  KeyboardKey.Pad9: 105,
  KeyboardKey.PadMultiply: 106,
  KeyboardKey.PadAdd: 107,
  KeyboardKey.PadSubtract: 109,
  KeyboardKey.PadPeriod: 110,
  KeyboardKey.PadDivide: 111,
  KeyboardKey.F1: 112,
  KeyboardKey.F2: 113,
  KeyboardKey.F3: 114,
  KeyboardKey.F4: 115,
  KeyboardKey.F5: 116,
  KeyboardKey.F6: 117,
  KeyboardKey.F7: 118,
  KeyboardKey.F8: 119,
  KeyboardKey.F9: 120,
  KeyboardKey.F10: 121,
  KeyboardKey.F11: 122,
  KeyboardKey.F12: 123,
  KeyboardKey.NumLock: 144,
  KeyboardKey.ScrollLock: 145,
  KeyboardKey.LeftShift: 160,
  KeyboardKey.RightShift: 161,
  KeyboardKey.LeftControl: 162,
  KeyboardKey.RightControl: 163,
  KeyboardKey.LeftAlt: 164,
  KeyboardKey.RightAlt: 165,
  KeyboardKey.Semicolon: 186,
  KeyboardKey.Equal: 187,
  KeyboardKey.Comma: 188,
  KeyboardKey.Minus: 189,
  KeyboardKey.Period: 190,
  KeyboardKey.Slash: 191,
  KeyboardKey.Backtick: 192,
  KeyboardKey.LeftBracket: 219,
  KeyboardKey.BackSlash: 220,
  KeyboardKey.RightBracket: 221,
  KeyboardKey.Quote: 222,
}.toBiTable()

proc keyboardHook(code: cint, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if code == HC_ACTION:
    let p: PKBDLLHOOKSTRUCT = cast[PKBDLLHOOKSTRUCT](lParam)
    let keyCode = p.vkCode
    let keyIndex = toKeyboardKey[keyCode]

    case wParam:
    of WM_KEYDOWN, WM_SYSKEYDOWN:
      osUi.frame.keyPresses.add keyIndex
      osUi.frame.keyDown[keyIndex] = true
    of WM_KEYUP, WM_SYSKEYUP:
      osUi.frame.keyReleases.add keyIndex
      osUi.frame.keyDown[keyIndex] = false
    else:
      discard

  CallNextHookEx(0, code, wParam, lParam)

# TODO: Figure out how to get horizontal mouse wheel state.
proc mouseHook(code: cint, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  if code == HC_ACTION:
    let hookStructPtr = cast[ptr MSLLHOOKSTRUCT](lParam)

    case wParam:
    of WM_MOUSEWHEEL:
      let delta = cast[int16](HIWORD(hookStructPtr.mouseData)) / WHEEL_DELTA
      osUi.frame.mouseWheel.y = delta
    of WM_XBUTTONDOWN, WM_XBUTTONDBLCLK,
       WM_NCXBUTTONDOWN, WM_NCXBUTTONDBLCLK:
      let buttonCode = HIWORD(hookStructPtr[].mouseData)
      case buttonCode:
      of XBUTTON1:
        osUi.frame.mousePresses.add Extra1
        osUi.frame.mouseDown[Extra1] = true
      of XBUTTON2:
        osUi.frame.mousePresses.add Extra2
        osUi.frame.mouseDown[Extra2] = true
      else: discard
    of WM_XBUTTONUP, WM_NCXBUTTONUP:
      let buttonCode = HIWORD(hookStructPtr[].mouseData)
      case buttonCode:
      of XBUTTON1:
        osUi.frame.mouseReleases.add Extra1
        osUi.frame.mouseDown[Extra1] = false
      of XBUTTON2:
        osUi.frame.mouseReleases.add Extra2
        osUi.frame.mouseDown[Extra2] = false
      else: discard
    of WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
       WM_NCLBUTTONDOWN, WM_NCLBUTTONDBLCLK:
      osUi.frame.mousePresses.add Left
      osUi.frame.mouseDown[Left] = true
    of WM_LBUTTONUP, WM_NCLBUTTONUP:
      osUi.frame.mouseReleases.add Left
      osUi.frame.mouseDown[Left] = false
    of WM_MBUTTONDOWN, WM_MBUTTONDBLCLK,
       WM_NCMBUTTONDOWN, WM_NCMBUTTONDBLCLK:
      osUi.frame.mousePresses.add Middle
      osUi.frame.mouseDown[Middle] = true
    of WM_MBUTTONUP, WM_NCMBUTTONUP:
      osUi.frame.mouseReleases.add Middle
      osUi.frame.mouseDown[Middle] = false
    of WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
       WM_NCRBUTTONDOWN, WM_NCRBUTTONDBLCLK:
      osUi.frame.mousePresses.add Right
      osUi.frame.mouseDown[Right] = true
    of WM_RBUTTONUP, WM_NCRBUTTONUP:
      osUi.frame.mouseReleases.add Right
      osUi.frame.mouseDown[Right] = false
    of WM_MOUSEMOVE, WM_NCMOUSEMOVE:
      osUi.frame.mousePositionPixels = vec2(hookStructPtr.pt.x.float, hookStructPtr.pt.y.float)
    else: discard

  CallNextHookEx(0, code, wParam, lParam)

proc update*() =
  osUi.update()
  var msg: MSG
  while PeekMessage(msg, 0, 0, 0, 0) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)

SetWindowsHookEx(WH_MOUSE_LL, mouseHook, 0, 0)
SetWindowsHookEx(WH_KEYBOARD_LL, keyboardHook, 0, 0)