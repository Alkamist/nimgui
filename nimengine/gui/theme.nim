import ../gmath

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