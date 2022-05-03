import pkg/nimengine

let window = newWindow()
window.enableRenderer()
window.renderer.setBackgroundColor(0.4, 0.4, 0.4, 1)

let canvas = newCanvas()
let theme = defaultTheme()

let guiButton = newButtonWidget(theme)
guiButton.x = 50
guiButton.y = 50
guiButton.width = 200
guiButton.height = 40
guiButton.onPressed = proc() = echo "Pressed."
guiButton.onReleased = proc() = echo "Released."

let guiWindow = newWindowWidget(theme)
guiWindow.x = 200
guiWindow.y = 200
guiWindow.width = 500
guiWindow.height = 300
guiWindow.addChild(guiButton)

let widgets = [guiWindow]

window.onUpdate = proc() =
  for widget in widgets:
    widget.update(window.input)

window.renderer.onRenderGui = proc() =
  canvas.reset()
  for widget in widgets:
    widget.draw(canvas)
  window.renderer.draw(canvas)

while not window.isClosed:
  window.update()