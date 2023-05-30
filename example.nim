import oswindow
import nimgui
import nimgui/imploswindow

const consolaData = readFile("consola.ttf")

let window = OsWindow.new()
window.setBackgroundColor(49 / 255, 51 / 255, 56 / 255)
window.setSize(800, 600)
window.show()

let root = Widget.newRoot()
root.vg.addFont("consola", consolaData)
root.attachToOsWindow(window)

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

root.drawHook:
  vg.beginPath()
  vg.rect(self.mousePosition + 0.5, vec2(200, 200))
  vg.strokeColor = rgb(255, 255, 255)
  vg.stroke()

window.run()