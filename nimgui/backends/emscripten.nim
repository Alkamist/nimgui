{.experimental: "overloadableEnums".}

import std/tables
import ../gui
import ./emscriptenapi

{.emit: """/*INCLUDESECTION*/
#include <emscripten/em_asm.h>
""".}

const canvas = "#canvas"

{.passL: "-s EXPORTED_RUNTIME_METHODS=ccall".}
{.passL: "-s EXPORTED_FUNCTIONS=_main,_onMousePress,_onMouseRelease,_onMouseMove,_onMouseWheel".}

emscripten_run_script("""
window.addEventListener("mousedown", (e) => {
  Module.ccall("onMousePress", null, ["number", "number", "number"], [e.button, e.clientX, e.clientY]);
});

window.addEventListener("mouseup", (e) => {
  Module.ccall("onMouseRelease", null, ["number", "number", "number"], [e.button, e.clientX, e.clientY]);
});

window.addEventListener("mousemove", (e) => {
  Module.ccall("onMouseMove", null, ["number", "number"], [e.clientX, e.clientY]);
});

window.addEventListener("wheel", (e) => {
  Module.ccall("onMouseWheel", null, ["number", "number"], [e.deltaX, e.deltaY]);
});
""")

proc getWindowWidth(): cint =
  {.emit: "result = EM_ASM_INT({ return window.innerWidth; });".}

proc getWindowHeight(): cint =
  {.emit: "result = EM_ASM_INT({ return window.innerHeight; });".}

proc getWindowContentScale(): cdouble =
  {.emit: "result = EM_ASM_DOUBLE(return window.devicePixelRatio);".}

proc setCursorImage(cursorName: cstring) =
  {.emit: ["EM_ASM(document.body.style.cursor = UTF8ToString($0), ", cursorName, ");"].}

var globalGui: Gui
var webGlContext: EMSCRIPTEN_WEBGL_CONTEXT_HANDLE

proc toMouseButton(jsCode: cint): MouseButton =
  case jsCode:
  of 0: MouseButton.Left
  of 1: MouseButton.Middle
  of 2: MouseButton.Right
  of 3: MouseButton.Extra1
  of 4: MouseButton.Extra2
  else: MouseButton.Unknown

proc toJsCursorStyle(style: CursorStyle): cstring =
  case style:
  of Arrow: cstring"default"
  of IBeam: cstring"text"
  of Crosshair: cstring"crosshair"
  of PointingHand: cstring"pointer"
  of ResizeLeftRight: cstring"ew-resize"
  of ResizeTopBottom: cstring"ns-resize"
  of ResizeTopLeftBottomRight: cstring"nwse-resize"
  of ResizeTopRightBottomLeft: cstring"nesw-resize"

const jsCodeToKeyboardKeyTable = {
  cstring"AltLeft": KeyboardKey.LeftAlt,
  cstring"AltRight": KeyboardKey.RightAlt,
  cstring"ArrowDown": KeyboardKey.DownArrow,
  cstring"ArrowLeft": KeyboardKey.LeftArrow,
  cstring"ArrowRight": KeyboardKey.RightArrow,
  cstring"ArrowUp": KeyboardKey.UpArrow,
  cstring"Backquote": KeyboardKey.Backtick,
  cstring"Backslash": KeyboardKey.Backslash,
  cstring"Backspace": KeyboardKey.Backspace,
  cstring"BracketLeft": KeyboardKey.LeftBracket,
  cstring"BracketRight": KeyboardKey.RightBracket,
  cstring"BrowserBack": KeyboardKey.Unknown,
  cstring"CapsLock": KeyboardKey.CapsLock,
  cstring"Comma": KeyboardKey.Comma,
  cstring"ContextMenu": KeyboardKey.Unknown,
  cstring"ControlLeft": KeyboardKey.LeftControl,
  cstring"ControlRight": KeyboardKey.RightControl,
  cstring"Delete": KeyboardKey.Delete,
  cstring"Digit0": KeyboardKey.Key0,
  cstring"Digit1": KeyboardKey.Key1,
  cstring"Digit2": KeyboardKey.Key2,
  cstring"Digit3": KeyboardKey.Key3,
  cstring"Digit4": KeyboardKey.Key4,
  cstring"Digit5": KeyboardKey.Key5,
  cstring"Digit6": KeyboardKey.Key6,
  cstring"Digit7": KeyboardKey.Key7,
  cstring"Digit8": KeyboardKey.Key8,
  cstring"Digit9": KeyboardKey.Key9,
  cstring"End": KeyboardKey.End,
  cstring"Enter": KeyboardKey.Enter,
  cstring"Equal": KeyboardKey.Equal,
  cstring"Escape": KeyboardKey.Escape,
  cstring"F1": KeyboardKey.F1,
  cstring"F10": KeyboardKey.F10,
  cstring"F11": KeyboardKey.F11,
  cstring"F12": KeyboardKey.F12,
  cstring"F13": KeyboardKey.Unknown,
  cstring"F14": KeyboardKey.Unknown,
  cstring"F15": KeyboardKey.Unknown,
  cstring"F16": KeyboardKey.Unknown,
  cstring"F17": KeyboardKey.Unknown,
  cstring"F18": KeyboardKey.Unknown,
  cstring"F19": KeyboardKey.Unknown,
  cstring"F2": KeyboardKey.F2,
  cstring"F20": KeyboardKey.Unknown,
  cstring"F21": KeyboardKey.Unknown,
  cstring"F22": KeyboardKey.Unknown,
  cstring"F23": KeyboardKey.Unknown,
  cstring"F24": KeyboardKey.Unknown,
  cstring"F3": KeyboardKey.F3,
  cstring"F4": KeyboardKey.F4,
  cstring"F5": KeyboardKey.F5,
  cstring"F6": KeyboardKey.F6,
  cstring"F7": KeyboardKey.F7,
  cstring"F8": KeyboardKey.F8,
  cstring"F9": KeyboardKey.F9,
  cstring"Fn": KeyboardKey.Unknown,
  cstring"Help": KeyboardKey.Unknown,
  cstring"Home": KeyboardKey.Home,
  cstring"Insert": KeyboardKey.Insert,
  cstring"KeyA": KeyboardKey.A,
  cstring"KeyB": KeyboardKey.B,
  cstring"KeyC": KeyboardKey.C,
  cstring"KeyD": KeyboardKey.D,
  cstring"KeyE": KeyboardKey.E,
  cstring"KeyF": KeyboardKey.F,
  cstring"KeyG": KeyboardKey.G,
  cstring"KeyH": KeyboardKey.H,
  cstring"KeyI": KeyboardKey.I,
  cstring"KeyJ": KeyboardKey.J,
  cstring"KeyK": KeyboardKey.K,
  cstring"KeyL": KeyboardKey.L,
  cstring"KeyM": KeyboardKey.M,
  cstring"KeyN": KeyboardKey.N,
  cstring"KeyO": KeyboardKey.O,
  cstring"KeyP": KeyboardKey.P,
  cstring"KeyQ": KeyboardKey.Q,
  cstring"KeyR": KeyboardKey.R,
  cstring"KeyS": KeyboardKey.S,
  cstring"KeyT": KeyboardKey.T,
  cstring"KeyU": KeyboardKey.U,
  cstring"KeyV": KeyboardKey.V,
  cstring"KeyW": KeyboardKey.W,
  cstring"KeyX": KeyboardKey.X,
  cstring"KeyY": KeyboardKey.Y,
  cstring"KeyZ": KeyboardKey.Z,
  cstring"MediaPlayPause": KeyboardKey.Unknown,
  cstring"MetaLeft": KeyboardKey.LeftMeta,
  cstring"MetaRight": KeyboardKey.RightMeta,
  cstring"Minus": KeyboardKey.Minus,
  cstring"NumLock": KeyboardKey.NumLock,
  cstring"Numpad0": KeyboardKey.Pad0,
  cstring"Numpad1": KeyboardKey.Pad1,
  cstring"Numpad2": KeyboardKey.Pad2,
  cstring"Numpad3": KeyboardKey.Pad3,
  cstring"Numpad4": KeyboardKey.Pad4,
  cstring"Numpad5": KeyboardKey.Pad5,
  cstring"Numpad6": KeyboardKey.Pad6,
  cstring"Numpad7": KeyboardKey.Pad7,
  cstring"Numpad8": KeyboardKey.Pad8,
  cstring"Numpad9": KeyboardKey.Pad9,
  cstring"NumpadAdd": KeyboardKey.PadAdd,
  cstring"NumpadDecimal": KeyboardKey.PadPeriod,
  cstring"NumpadDivide": KeyboardKey.PadDivide,
  cstring"NumpadEnter": KeyboardKey.PadEnter,
  cstring"NumpadEqual": KeyboardKey.Unknown,
  cstring"NumpadMultiply": KeyboardKey.PadMultiply,
  cstring"NumpadSubtract": KeyboardKey.PadSubtract,
  cstring"PageDown": KeyboardKey.PageDown,
  cstring"PageUp": KeyboardKey.PageUp,
  cstring"Pause": KeyboardKey.Pause,
  cstring"Period": KeyboardKey.Period,
  cstring"Power": KeyboardKey.Unknown,
  cstring"PrintScreen": KeyboardKey.PrintScreen,
  cstring"Quote": KeyboardKey.Quote,
  cstring"ScrollLock": KeyboardKey.ScrollLock,
  cstring"Semicolon": KeyboardKey.Semicolon,
  cstring"ShiftLeft": KeyboardKey.LeftShift,
  cstring"ShiftRight": KeyboardKey.RightShift,
  cstring"Slash": KeyboardKey.Slash,
  cstring"Space": KeyboardKey.Space,
  cstring"Tab": KeyboardKey.Tab,
}.toTable

const eventKeyCodes = [
  cstring"AVRInput", "AVRPower", "Accept", "Again", "AllCandidates", "Alphanumeric", "Alt", "AltGraph", "AppSwitch",
  "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowUp", "Attn", "AudioBalanceLeft", "AudioBalanceRight",
  "AudioBassBoostDown", "AudioBassBoostToggle", "AudioBassBoostUp", "AudioFaderFront", "AudioFaderRear",
  "AudioSurroundModeNext", "AudioTrebleDown", "AudioTrebleUp", "AudioVolumeDown", "AudioVolumeMute",
  "AudioVolumeUp", "Backspace", "BrightnessDown", "BrightnessUp", "BrowserBack", "BrowserFavorites",
  "BrowserForward", "BrowserHome", "BrowserRefresh", "BrowserSearch", "BrowserStop", "Call", "Camera",
  "CameraFocus", "Cancel", "CapsLock", "ChannelDown", "ChannelUp", "Clear", "Close", "ClosedCaptionToggle",
  "CodeInput", "ColorF0Red", "ColorF1Green", "ColorF2Yellow", "ColorF3Blue", "ColorF4Grey", "ColorF5Brown",
  "Compose", "ContextMenu", "Control", "Convert", "Copy", "CrSel", "Cut", "DVR", "Dead", "Delete", "Dimmer",
  "DisplaySwap", "Eisu", "Eject", "End", "EndCall", "Enter", "EraseEof", "Escape", "ExSel", "Execute", "Exit",
  "F1", "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19", "F2",
  "F20", "F21", "F22", "F23", "F24", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "FavoriteClear0",
  "FavoriteClear1", "FavoriteClear2", "FavoriteClear3", "FavoriteRecall0", "FavoriteRecall1",
  "FavoriteRecall2", "FavoriteRecall3", "FavoriteStore0", "FavoriteStore1", "FavoriteStore2",
  "FavoriteStore3", "FinalMode", "Find", "Fn", "FnLock", "GoBack", "GoHome", "GroupFirst", "GroupLast",
  "GroupNext", "GroupPrevious", "Guide", "GuideNextDay", "GuidePreviousDay", "HangulMode", "HanjaMode",
  "Hankaku", "HeadsetHook", "Help", "Hibernate", "Hiragana", "HiraganaKatakana", "Home", "Hyper", "Info",
  "Insert", "InstantReplay", "JunjaMode", "KanaMode", "KanjiMode", "Katakana", "Key11", "Key12",
  "LastNumberRedial", "LaunchApplication1", "LaunchApplication2", "LaunchCalendar", "LaunchContacts",
  "LaunchMail", "LaunchMediaPlayer", "LaunchMusicPlayer", "LaunchPhone", "LaunchScreenSaver",
  "LaunchSpreadsheet", "LaunchWebBrowser", "LaunchWebCam", "LaunchWordProcessor", "Link", "ListProgram",
  "LiveContent", "Lock", "LogOff", "MailForward", "MailReply", "MailSend", "MannerMode", "MediaApps",
  "MediaAudioTrack", "MediaClose", "MediaFastForward", "MediaLast", "MediaPause", "MediaPlay",
  "MediaPlayPause", "MediaRecord", "MediaRewind", "MediaSkipBackward", "MediaSkipForward",
  "MediaStepBackward", "MediaStepForward", "MediaStop", "MediaTopMenu", "MediaTrackNext",
  "MediaTrackPrevious", "Meta", "MicrophoneToggle", "MicrophoneVolumeDown", "MicrophoneVolumeMute",
  "MicrophoneVolumeUp", "ModeChange", "NavigateIn", "NavigateNext", "NavigateOut", "NavigatePrevious", "New",
  "NextCandidate", "NextFavoriteChannel", "NextUserProfile", "NonConvert", "Notification", "NumLock",
  "OnDemand", "Open", "PageDown", "PageUp", "Pairing", "Paste", "Pause", "PinPDown", "PinPMove", "PinPToggle",
  "PinPUp", "Play", "PlaySpeedDown", "PlaySpeedReset", "PlaySpeedUp", "Power", "PowerOff",
  "PreviousCandidate", "Print", "PrintScreen", "Process", "Props", "RandomToggle", "RcLowBattery",
  "RecordSpeedNext", "Redo", "RfBypass", "Romaji", "STBInput", "STBPower", "Save", "ScanChannelsToggle",
  "ScreenModeNext", "ScrollLock", "Select", "Settings", "Shift", "SingleCandidate",
  "Soft1", "Soft10", "Soft2", "Soft3", "Soft4", "Soft5", "Soft6", "Soft7", "Soft8", "Soft9",
  "SpeechCorrectionList", "SpeechInputToggle", "SpellCheck", "SplitScreenToggle", "Standby",
  "Subtitle", "Super", "Symbol", "SymbolLock", "TV", "TV3DMode", "TVAntennaCable", "TVAudioDescription",
  "TVAudioDescriptionMixDown", "TVAudioDescriptionMixUp", "TVContentsMenu", "TVDataService", "TVInput",
  "TVInputComponent1", "TVInputComponent2", "TVInputComposite1", "TVInputComposite2", "TVInputHDMI1",
  "TVInputHDMI2", "TVInputHDMI3", "TVInputHDMI4", "TVInputVGA1", "TVMediaContext", "TVNetwork",
  "TVNumberEntry", "TVPower", "TVRadioService", "TVSatellite", "TVSatelliteBS", "TVSatelliteCS",
  "TVSatelliteToggle", "TVTerrestrialAnalog", "TVTerrestrialDigital", "TVTimer", "Tab", "Teletext",
  "Undo", "Unidentified", "VideoModeNext", "VoiceDial", "WakeUp", "Wink", "Zenkaku", "ZenkakuHankaku",
  "ZoomIn", "ZoomOut", "ZoomToggle",
]

proc isTextInput(jsKey: cstring): bool =
  jsKey notin eventKeyCodes

proc toKeyboardKey(jsCode: cstring): KeyboardKey =
  jsCodeToKeyboardKeyTable[jsCode]

proc updateCursorStyle(gui: Gui) =
  setCursorImage(gui.cursorStyle.toJsCursorStyle)

proc closeRequested*(gui: Gui): bool =
  false

proc makeContextCurrent*(gui: Gui) =
  discard emscripten_webgl_make_context_current(webGlContext)

proc pollEvents*(gui: Gui) =
  discard

proc swapBuffers*(gui: Gui) =
  discard

proc show*(gui: Gui) =
  discard

proc hide*(gui: Gui) =
  discard

proc close*(gui: Gui) =
  discard

proc processFrame*(gui: Gui) =
  gui.inputTime(emscripten_performance_now() * 0.001)
  gui.inputContentScale(getWindowContentScale())
  gui.beginFrame()
  if gui.onFrame != nil:
    gui.onFrame(gui)
  gui.endFrame()
  if gui.isHovered:
    gui.updateCursorStyle()

proc mainLoop() {.cdecl.} =
  globalGui.makeContextCurrent()
  globalGui.processFrame()

proc run*(gui: Gui) =
  emscripten_set_main_loop(mainLoop, 0, EM_TRUE)

proc onResize(eventType: cint, uiEvent: ptr EmscriptenUiEvent, userData: pointer): EM_BOOL {.cdecl.} =
  globalGui.inputSize(float(uiEvent.windowInnerWidth), float(uiEvent.windowInnerHeight))
  discard emscripten_set_canvas_element_size(canvas, uiEvent.windowInnerWidth, uiEvent.windowInnerHeight)

proc onMousePress(button: cint, x, y: cdouble) {.exportc.} =
  globalGui.inputMousePress(button.toMouseButton)

proc onMouseRelease(button: cint, x, y: cdouble) {.exportc.} =
  globalGui.inputMouseRelease(button.toMouseButton)

proc onMouseWheel(x, y: cdouble) {.exportc.} =
  globalGui.inputMouseWheel(x * 0.01, y * -0.01)

proc onMouseMove(x, y: cdouble) {.exportc.} =
  globalGui.inputMouseMove(x, y)
  globalGui.updateCursorStyle()

proc onMouseEnter(eventType: cint; mouseEvent: ptr EmscriptenMouseEvent; userData: pointer): EM_BOOL {.cdecl.} =
  globalGui.inputMouseEnter()

proc onMouseExit(eventType: cint; mouseEvent: ptr EmscriptenMouseEvent; userData: pointer): EM_BOOL {.cdecl.} =
  globalGui.inputMouseExit()

proc onKeyPress(eventType: cint, keyEvent: ptr EmscriptenKeyboardEvent, userData: pointer): EM_BOOL {.cdecl.} =
  globalGui.inputKeyPress(cast[cstring](addr(keyEvent.code[0])).toKeyboardKey)
  let possibleText = cast[cstring](addr(keyEvent.key[0]))
  if possibleText.isTextInput:
    globalGui.inputText($possibleText)

proc onKeyRelease(eventType: cint, keyEvent: ptr EmscriptenKeyboardEvent, userData: pointer): EM_BOOL {.cdecl.} =
  globalGui.inputKeyRelease(cast[cstring](addr(keyEvent.code[0])).toKeyboardKey)

proc setupBackend*(gui: Gui) =
  globalGui = gui

  let width = getWindowWidth()
  let height = getWindowHeight()
  gui.inputSize(float(width), float(height))
  discard emscripten_set_canvas_element_size(canvas, width, height)

  var attributes: EmscriptenWebGLContextAttributes
  emscripten_webgl_init_context_attributes(addr(attributes))
  attributes.stencil = true.EM_BOOL
  attributes.depth = true.EM_BOOL
  webGlContext = emscripten_webgl_create_context(canvas, addr(attributes))

  gui.makeContextCurrent()
  gui.setupVectorGraphics()

  discard emscripten_set_mouseenter_callback(canvas, nil, EM_BOOL(true), onMouseEnter)
  discard emscripten_set_mouseleave_callback(canvas, nil, EM_BOOL(true), onMouseExit)
  discard emscripten_set_resize_callback(EMSCRIPTEN_EVENT_TARGET_WINDOW, nil, EM_BOOL(true), onResize)
  discard emscripten_set_keydown_callback(EMSCRIPTEN_EVENT_TARGET_WINDOW, nil, EM_BOOL(true), onKeyPress)
  discard emscripten_set_keyup_callback(EMSCRIPTEN_EVENT_TARGET_WINDOW, nil, EM_BOOL(true), onKeyRelease)