import ./nimgui/oswindow
import ./nimgui/gfxmod

let window = newOsWindow()
GC_ref(window)
window.backgroundColor = rgb(123, 20, 180)

let gfx = newGfx()
GC_ref(gfx)

window.onFrame = proc() =
  gfx.beginFrame(window.sizePixels, window.pixelDensity)



  gfx.beginPath()
  gfx.moveTo(window.mousePosition)
  gfx.lineTo(window.mousePosition + vec2(0, 400))
  gfx.lineTo(window.mousePosition + vec2(300, 300))
  gfx.lineTo(window.mousePosition + vec2(400, 0))
  gfx.closePath()
  gfx.fillColor = rgb(120, 120, 120)
  gfx.fill()
  gfx.strokeWidth = 1.0
  gfx.strokeColor = rgba(255, 255, 255, 255)

  gfx.saveState()
  gfx.translate(vec2(-0.5, -0.5))
  gfx.stroke()
  gfx.restoreState()

  gfx.endFrame(window.sizePixels)

while window.isOpen:
  window.process()