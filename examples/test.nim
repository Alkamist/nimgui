{.experimental: "overloadableEnums".}

import ../nimengine

const consolaData = staticRead("consola.ttf")

let window = newWindow()
window.backgroundColor = rgb(16, 16, 16)
window.gfx.addFont("consola", consolaData)

const amount = 5

var buttons: seq[GuiButton]
for i in 0 ..< amount:
  for j in 0 ..< amount:
    let b = GuiButton()
    b.mouseTriggers = {MouseButton.Left, Middle}
    buttons.add b

window.onFrame = proc() =
  let width = window.width / amount
  let height = window.height / amount
  for i in 0 ..< amount:
    for j in 0 ..< amount:
      let b = buttons[i * amount + j]
      b.bounds = rect2(
        i.float * width,
        j.float * height,
        width * 0.9,
        height * 0.9,
      )
      b.label = $b.bounds.x

      b.update(window)

      if b.clicked:
        echo "Clicked"

      b.draw(window)

while window.exists:
  pollEvents()
  window.update()