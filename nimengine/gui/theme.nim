import ../gmath
export gmath

type
  Color* = tuple[r, g, b, a: float]

func rgb*(r, g, b: uint8): Color =
  (r: r.float / 255, g: g.float / 255, b: b.float / 255, a: 1.0)

const main = rgb(54, 57, 63)
const button = main.lightened(0.15)
const border = rgb(15, 15, 16)

const defaultColors* = (
  main: main,
  dark: rgb(32, 34, 37),
  border: border,
  button: button,
  buttonHovered: button.lightened(0.2),
  buttonDown: border,
)