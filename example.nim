import std/sequtils
import std/times
import opengl
import oswindow
import nimgui
import nimgui/imploswindow

var windows: seq[OsWindow]

proc processFrame(window: OsWindow) =
  window.makeContextCurrent()

  let (width, height) = window.size
  glViewport(0, 0, int32(width), int32(height))
  glClearColor(0.1, 0.1, 0.1, 1.0)
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
  root.attachToOsWindow(window, processFrame)

  root.drawHook:
    vg.beginPath()
    vg.rect(50, 50, 200, 200)
    vg.setFillColor(1, 0, 0, 1)
    vg.fill()

while windows.len > 0:
  for window in windows:
    window.pollEvents()
    if window.isOpen:
      processFrame(window)

  windows.keepItIf(it.isOpen)