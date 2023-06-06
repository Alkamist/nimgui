# {.experimental: "overloadableEnums".}

# import nimgui

# let gui = Gui.new()

# const consolaData = readFile("consola.ttf")
# gui.vg.addFont("consola", consolaData)

# var frames = 0

# gui.onFrame:
#   frames += 1
#   let fpsCount = float(frames) / gui.time

#   gui.childSpacing = vec2(1, 1)
#   gui.childSize = gui.size

#   for i in gui.grid(100, 100):
#     let button = gui.addButton("GridButton" & $i)
#     button.draw:
#       let vg = button.vg
#       vg.beginPath()
#       vg.rect(vec2(0, 0), button.size)
#       vg.fillColor = rgb(100, 100, 100)
#       vg.fill()

#   gui.freePosition()

#   let fps = gui.addText("Fps")
#   fps.alignX = Left
#   fps.alignY = Baseline
#   fps.data = $fpsCount

# gui.run()