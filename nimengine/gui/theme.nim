import ../tmath

const main = rgb(54, 57, 63)
const button = main.lighten(0.15)
const border = rgb(15, 15, 16)
const text = rgb(245, 245, 245)

const defaultColors* = (
  main: main,
  dark: rgb(32, 34, 37),
  text: text,
  border: border,
  button: button,
  buttonHovered: button.lighten(0.2),
  buttonDown: border,
)