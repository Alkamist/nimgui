{.experimental: "overloadableEnums".}

import ../nimengine

# const consolaData = staticRead("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)

while gui.isOpen:
  gui.update()