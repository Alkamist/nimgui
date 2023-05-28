import std/sequtils
import std/times
import opengl
import oswindow
import nimgui
import nimgui/imploswindow

const consolaData = readFile("consola.ttf")

var windows: seq[OsWindow]

proc processFrame(window: OsWindow) =
  window.makeContextCurrent()

  let (width, height) = window.size
  glViewport(0, 0, int32(width), int32(height))
  glClearColor(49 / 255, 51 / 255, 56 / 255, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  let root = cast[Widget](window.userData)
  root.processFrame(cpuTime())

  window.swapBuffers()

for i in 0 ..< 4:
  let window = OsWindow.new()
  windows.add(window)
  window.setSize(400, 300)
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

  # let b = window2.addButton()
  # b.position = vec2(50, 50)
  # b.addLabel("Hello")

  # root.drawHook:
  #   vg.beginPath()
  #   vg.rect(self.mousePosition, vec2(200, 200))
  #   vg.fillColor = rgb(255, 0, 0)
  #   vg.fill()

while windows.len > 0:
  for window in windows:
    window.pollEvents()
    if window.isOpen:
      processFrame(window)

  windows.keepItIf(it.isOpen)