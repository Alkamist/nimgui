import pkg/nimengine

let window = newWindow()
window.enableRenderer()
# window.renderer.setBackgroundColor(18 / 255, 19 / 255, 23 / 255, 1)
window.renderer.setBackgroundColor(128 / 255, 128 / 255, 128 / 255, 1)

let canvas = newCanvas(window.width, window.height)

let guiButton = newButtonWidget()
guiButton.x = 50
guiButton.y = 50
guiButton.width = 200
guiButton.height = 40
guiButton.onPressed = proc() = echo "Pressed 1"
guiButton.onReleased = proc() = echo "Released 1"

let guiWindow = newWindowWidget()
guiWindow.x = 200
guiWindow.y = 200
guiWindow.width = 500
guiWindow.height = 300
guiWindow.addChild(guiButton)

let guiButton2 = newButtonWidget()
guiButton2.x = 50
guiButton2.y = 50
guiButton2.width = 200
guiButton2.height = 40
guiButton2.onPressed = proc() = echo "Pressed 2"
guiButton2.onReleased = proc() = echo "Released 2"

let guiWindow2 = newWindowWidget()
guiWindow2.x = 500
guiWindow2.y = 300
guiWindow2.width = 500
guiWindow2.height = 300
guiWindow2.addChild(guiButton2)

let gui = newWidget()
gui.width = window.width
gui.height = window.height
gui.addChild(guiWindow)
gui.addChild(guiWindow2)

window.onResize = proc() =
  canvas.width = window.width
  canvas.height = window.height
  gui.width = window.width
  gui.height = window.height

window.onUpdate = proc() =
  gui.update(window.input)

window.renderer.onRenderGui = proc() =
  canvas.reset()
  gui.draw(canvas)
  window.renderer.draw(canvas)

while not window.isClosed:
  window.update()