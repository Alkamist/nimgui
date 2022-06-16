{.experimental: "overloadableEnums".}

import ../nimengine

# const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(8, 8, 8)

# gui.onFrame = proc() =
#   gui.window("Window"):
#     if gui.button("Button"):
#       echo "Yee"

while gui.isOpen:
  gui.update()