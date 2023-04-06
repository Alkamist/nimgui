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
  gfx.circle(window.mousePosition, 50)
  gfx.fillColor = rgb(255, 255, 255)
  gfx.fill()
  gfx.endFrame(window.sizePixels)

while window.isOpen:
  window.process()