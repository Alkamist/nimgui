import ./widget
import ./container

type
  Gui* = ref object of ContainerWidget

func newGui*(input: Input): Gui =
  Gui(
    canvas: newCanvas(),
    input: input,
  )

method update*(gui: Gui) =
  gui.updateChildren()

method draw*(gui: Gui) =
  gui.canvas.reset()
  gui.drawChildren()