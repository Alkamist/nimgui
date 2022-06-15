{.experimental: "overloadableEnums".}

import ../nimengine

# const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

gui.onFrame = proc() =
  gui.window("Window"):
    if gui.button("Button"):
      echo "Yee"

while gui.isOpen:
  gui.update()