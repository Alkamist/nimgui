import ../gmath

const main = rgbaU(54, 57, 63, 255)
const button = main.lightened(0.15)
const border = rgbaU(15, 15, 16, 255)

const defaultColors* = (
  main: main,
  dark: rgbaU(32, 34, 37, 255),
  border: border,
  button: button,
  buttonHovered: button.lightened(0.2),
  buttonPressed: border,
)