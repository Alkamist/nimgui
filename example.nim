import nimgui
import nimgui/widgets

const fontData = readFile("consola.ttf")

let consola = Font.new()
consola.name = "Consola"
consola.data = fontData

let window1 = Window.new()
window1.title = "Window 1"
window1.position = vec2(50, 50)
window1.backgroundColor = rgb(16, 16, 16)

window1.defaultFont = consola

window1.onFrame = proc(window: Window) =
  let path = Path.new()
  path.roundedRect(vec2(50, 50), vec2(100, 100), 5)
  path.close()
  window.fillPath(path, rgb(255, 0, 0))

let window2 = Window.new()
window2.title = "Window 2"
window2.position = vec2(500, 50)
window2.backgroundColor = rgb(16, 16, 16)

window2.defaultFont = consola

let button = Button.new()
button.position = vec2(10, 50)

let slider = Slider.new()
slider.position = vec2(100, 100)

let performance = Performance.new()

window2.onFrame = proc(window: Window) =
  button.update()
  button.draw()

  slider.update()
  slider.draw()

  if button.clicked:
    if window1.isOpen:
      window1.close()
    else:
      window1.open()

  performance.update()
  performance.draw()

window1.open()
window2.open()

while window1.isOpen or window2.isOpen:
  gui.update()