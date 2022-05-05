import ../input
export input

when defined(windows):
  import winim/lean except INPUT
  type
    WindowPlatformData* = object
      handle*: HWND
      lastCursorPosX*: float
      lastCursorPosY*: float
      restoreCursorPosX*: float
      restoreCursorPosY*: float
      isTrackingMouse*: bool

type
  Window* = ref object
    time*: float
    previousTime*: float
    delta*: float

    x*, y*: float
    previousX*, previousY*: float
    xChange*, yChange*: float
    width*, height*: float
    previousWidth*, previousHeight*: float
    widthChange*, heightChange*: float
    isFocused*: bool
    isClosed*: bool
    isChild*: bool

    cursorIsOver*: bool
    cursorIsConfined*: bool
    cursorIsPinnedToCenter*: bool
    cursorIsHidden*: bool

    onClose*: proc()
    onFocus*: proc()
    onLoseFocus*: proc()
    onMove*: proc()
    onResize*: proc()
    onMouseMove*: proc()
    onMouseEnter*: proc()
    onMouseExit*: proc()
    onMouseWheel*: proc()
    onMousePress*: proc()
    onMouseRelease*: proc()
    onKeyPress*: proc()
    onKeyRelease*: proc()
    onCharacter*: proc()

    input*: Input
    platform*: WindowPlatformData