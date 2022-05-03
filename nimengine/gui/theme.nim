import ../gmath

type
  ThemeColors* = object
    text*: Color
    border*: Color
    windowBackground*: Color
    titleBackground*: Color
    titleText*: Color
    button*: Color
    buttonHovered*: Color
    buttonPressed*: Color

  Theme* = ref object
    padding*: float
    spacing*: float
    indent*: float
    titleBarHeight*: float
    scrollBarSize*: float
    colors*: ThemeColors

func defaultTheme*(): Theme =
  Theme(
    padding: 5,
    spacing: 4,
    indent: 24,
    titleBarHeight: 24,
    scrollBarSize: 12,
    colors: ThemeColors(
      text: rgba(0.9, 0.9, 0.9, 1),
      border: rgba(0.1, 0.1, 0.1, 1),
      windowBackground: rgba(0.2, 0.2, 0.2, 1),
      titleBackground: rgba(0.1, 0.1, 0.1, 1),
      titleText: rgba(0.9, 0.9, 0.9, 1),
      button: rgba(0.3, 0.3, 0.3, 1),
      buttonHovered: rgba(0.37, 0.37, 0.37, 1),
      buttonPressed: rgba(0.14, 0.14, 0.14, 1),
    ),
  )