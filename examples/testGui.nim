import pkg/nimengine

let window = newWindow()
window.enableRenderer()
window.renderer.setBackgroundColor(54 / 255, 57 / 255, 63 / 255, 1)

let canvas = newCanvas(window.width, window.height)

let gui = newWidget()
gui.width = window.width
gui.height = window.height

for i in 0 ..< 50:
  let b = newButtonWidget()
  b.x = 20
  b.y = 40
  b.width = 50
  b.height = 50
  closureScope:
    let windowNumber = i + 1
    b.onPressed = proc() =
      echo "Pressed " & $windowNumber
    b.onReleased = proc() =
      echo "Released " & $windowNumber

  let w = newWindowWidget()
  w.x = i.float * 10.0
  w.y = i.float * 10.0
  w.width = 300
  w.height = 200
  w.addChild(b)

  gui.addChild(w)

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