import nimgui
# import nimgui/widgets

const fontData = readFile("consola.ttf")

proc windowProc() {.thread.} =
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

  window1.open()

  while window1.isOpen:
    gui.update()

var t0: Thread[void]
var t1: Thread[void]

createThread(t0, windowProc)
createThread(t1, windowProc)

joinThreads(t0, t1)