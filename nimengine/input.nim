{.experimental: "overloadableEnums".}

type
  MouseButton* = enum
    unknown
    left
    middle
    right
    extra1
    extra2
    extra3
    extra4
    extra5

  KeyboardKey* = enum
    unknown
    a
    b
    c
    d
    e
    f
    g
    h
    i
    j
    k
    l
    m
    n
    o
    p
    q
    r
    s
    t
    u
    v
    w
    x
    y
    z
    key1
    key2
    key3
    key4
    key5
    key6
    key7
    key8
    key9
    key0
    pad1
    pad2
    pad3
    pad4
    pad5
    pad6
    pad7
    pad8
    pad9
    pad0
    f1
    f2
    f3
    f4
    f5
    f6
    f7
    f8
    f9
    f10
    f11
    f12
    backtick
    minus
    equal
    backspace
    tab
    capsLock
    enter
    leftShift
    rightShift
    leftControl
    rightControl
    leftAlt
    rightAlt
    leftMeta
    rightMeta
    leftBracket
    rightBracket
    space
    escape
    backslash
    semicolon
    quote
    comma
    period
    slash
    scrollLock
    pause
    insert
    keyEnd
    pageUp
    delete
    home
    pageDown
    leftArrow
    rightArrow
    downArrow
    upArrow
    numLock
    padDivide
    padMultiply
    padSubtract
    padAdd
    padEnter
    padPeriod

  Input* = ref object
    lastMousePress*: MouseButton
    lastMouseRelease*: MouseButton
    mouseX*, mouseY*: float
    mouseXChange*, mouseYChange*: float
    previousMouseX*, previousMouseY*: float
    mouseWheelX*, mouseWheelY*: float
    mouseDown*: array[MouseButton, bool]
    mousePressed*: array[MouseButton, bool]
    mouseReleased*: array[MouseButton, bool]
    previousMouseDown*: array[MouseButton, bool]
    lastKeyPress*: KeyboardKey
    lastKeyRelease*: KeyboardKey
    keyDown*: array[KeyboardKey, bool]
    keyPressed*: array[KeyboardKey, bool]
    keyReleased*: array[KeyboardKey, bool]
    previousKeyDown*: array[KeyboardKey, bool]
    text*: string

func newInput*(): Input =
  Input()

func update*(input: Input) =
  input.mouseXChange = input.mouseX - input.previousMouseX
  input.mouseYChange = input.mouseY - input.previousMouseY
  input.previousMouseX = input.mouseX
  input.previousMouseY = input.mouseY

  for button in MouseButton:
    input.mousePressed[button] = input.mouseDown[button] and not input.previousMouseDown[button]
    input.mouseReleased[button] = input.previousMouseDown[button] and not input.mouseDown[button]

  input.previousMouseDown = input.mouseDown

  for key in KeyboardKey:
    input.keyPressed[key] = input.keyDown[key] and not input.previousKeyDown[key]
    input.keyReleased[key] = input.previousKeyDown[key] and not input.keyDown[key]

  input.previousKeyDown = input.keyDown

  input.text = ""