{.experimental: "overloadableEnums".}

import ../nimengine

const consolaData = staticRead("consola.ttf")

let w = newWindow()
w.backgroundColor = rgb(13, 17, 23)

let gui = newGui(w)
discard gui.addFont(consolaData, 13)

w.onFrame = proc() =
  # if w.mouseDown(Middle) and w.mouseMoved:
  #   let zoomPull = w.mouseDeltaPixels.dot(vec2(1, 1).normalize)
  #   w.frame.pixelDensity *= 2.0.pow(zoomPull * 0.005)
  #   w.frame.pixelDensity = w.frame.pixelDensity.clamp(0.25, 5.0)

  gui.beginFrame()

  gui.window("Window"):
    var i = 0
    for row in 0 ..< 50:
      for col in 0 ..< 50:
        if col > 0:
          gui.sameRow()
        if gui.button("Button " & $i):
          echo "Clicked " & $i
        inc i

    # if gui.button("Button"):
    #   echo "Yee"

  gui.endFrame()

while w.isOpen:
  w.update()