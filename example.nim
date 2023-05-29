import std/times
import opengl
import oswindow
import nimgui
import nimgui/imploswindow

const consolaData = readFile("consola.ttf")

proc processFrame(window: OsWindow) =
  window.makeContextCurrent()

  let (width, height) = window.size
  glViewport(0, 0, int32(width), int32(height))
  glClearColor(49 / 255, 51 / 255, 56 / 255, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  let root = cast[Widget](window.userData)
  root.processFrame(cpuTime())

  window.swapBuffers()

let window = OsWindow.new()
window.setSize(800, 600)
window.show()

opengl.loadExtensions()

let root = Widget.newRoot()
root.vg.addFont("consola", consolaData)
root.attachToOsWindow(window, processFrame)

let window1 = root.addWindow()
window1.position = vec2(50, 50)
window1.size = vec2(500, 500)
window1.addTitle("Window 1")

let window2 = window1.body.addWindow()
window2.position = vec2(50, 50)
window2.size = vec2(400, 300)
window2.addTitle("Child Window")

let b = window2.body.addButton()
b.position = vec2(50, 50)
b.addLabel("Hello")

let window3 = root.addWindow()
window3.position = vec2(600, 50)
window3.size = vec2(500, 500)
window3.addTitle("Window 2")

let window4 = window3.body.addWindow()
window4.position = vec2(50, 50)
window4.size = vec2(400, 300)
window4.addTitle("Child Window")

# root.drawHook:
#   vg.beginPath()
#   vg.rect(self.mousePosition, vec2(200, 200))
#   vg.fillColor = rgb(255, 0, 0)
#   vg.fill()

while window.isOpen:
  window.pollEvents()
  if window.isOpen:
    processFrame(window)