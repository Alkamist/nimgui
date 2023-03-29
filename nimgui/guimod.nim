{.experimental: "overloadableEnums".}

import ./oswindow; export oswindow
import ./drawlist/drawlist; export drawlist
import ./drawlist/drawlistrenderernanovg

type
  Gui* = ref object
    osWindow*: OsWindow
    renderer*: DrawListRenderer
    gfx*: DrawList
    storedBackgroundColor: Color

# template x*(widget: Widget): auto = widget.position.x
# template `x=`*(widget: Widget, value: float) = widget.position.x = value
# template y*(widget: Widget): auto = widget.position.y
# template `y=`*(widget: Widget, value: float) = widget.position.y = value
# template width*(widget: Widget): auto = widget.size.x
# template `width=`*(widget: Widget, value: float) = widget.size.x = value
# template height*(widget: Widget): auto = widget.size.y
# template `height=`*(widget: Widget, value: float) = widget.size.y = value

template update*(gui: Gui) = gui.osWindow.update()
template isOpen*(gui: Gui): bool = gui.osWindow.isOpen
template time*(gui: Gui): float = gui.osWindow.time
template isFocused*(gui: Gui): bool = gui.osWindow.isFocused
template isHovered*(gui: Gui): bool = gui.osWindow.isHovered
template pixelDensity*(gui: Gui): float = gui.osWindow.pixelDensity
template boundsPixels*(gui: Gui): Rect2 = gui.osWindow.boundsPixels
template mousePositionPixels*(gui: Gui): Vec2 = gui.osWindow.mousePositionPixels
template mouseWheel*(gui: Gui): Vec2 = gui.osWindow.mouseWheel
template mousePresses*(gui: Gui): seq[MouseButton] = gui.osWindow.mousePresses
template mouseReleases*(gui: Gui): seq[MouseButton] = gui.osWindow.mouseReleases
template mouseDown*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseDown(button)
template keyPresses*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyPresses
template keyReleases*(gui: Gui): seq[KeyboardKey] = gui.osWindow.keyReleases
template keyDown*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyDown(key)
template text*(gui: Gui): string = gui.osWindow.text
template deltaTime*(gui: Gui): float = gui.osWindow.deltaTime
template mousePosition*(gui: Gui): Vec2 = gui.osWindow.mousePosition
template mouseDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.mouseDeltaPixels
template mouseDelta*(gui: Gui): Vec2 = gui.osWindow.mouseDelta
template mouseMoved*(gui: Gui): bool = gui.osWindow.mouseMoved
template mouseWheelMoved*(gui: Gui): bool = gui.osWindow.mouseWheelMoved
template mousePressed*(gui: Gui, button: MouseButton): bool = gui.osWindow.mousePressed(button)
template mouseReleased*(gui: Gui, button: MouseButton): bool = gui.osWindow.mouseReleased(button)
template anyMousePressed*(gui: Gui): bool = gui.osWindow.anyMousePressed
template anyMouseReleased*(gui: Gui): bool = gui.osWindow.anyMouseReleased
template keyPressed*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyPressed(key)
template keyReleased*(gui: Gui, key: KeyboardKey): bool = gui.osWindow.keyReleased(key)
template anyKeyPressed*(gui: Gui): bool = gui.osWindow.anyKeyPressed
template anyKeyReleased*(gui: Gui): bool = gui.osWindow.anyKeyReleased
template bounds*(gui: Gui): Rect2 = gui.osWindow.bounds
template positionPixels*(gui: Gui): Vec2 = gui.osWindow.positionPixels
template xPixels*(gui: Gui): float = gui.osWindow.xPixels
template yPixels*(gui: Gui): float = gui.osWindow.yPixels
template position*(gui: Gui): Vec2 = gui.osWindow.position
template x*(gui: Gui): float = gui.osWindow.x
template y*(gui: Gui): float = gui.osWindow.y
template sizePixels*(gui: Gui): Vec2 = gui.osWindow.sizePixels
template widthPixels*(gui: Gui): float = gui.osWindow.widthPixels
template heightPixels*(gui: Gui): float = gui.osWindow.heightPixels
template size*(gui: Gui): Vec2 = gui.osWindow.size
template width*(gui: Gui): float = gui.osWindow.width
template height*(gui: Gui): float = gui.osWindow.height
template scale*(gui: Gui): float = gui.osWindow.scale
template moved*(gui: Gui): bool = gui.osWindow.moved
template positionDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.positionDeltaPixels
template positionDelta*(gui: Gui): Vec2 = gui.osWindow.positionDelta
template resized*(gui: Gui): bool = gui.osWindow.resized
template sizeDeltaPixels*(gui: Gui): Vec2 = gui.osWindow.sizeDeltaPixels
template sizeDelta*(gui: Gui): Vec2 = gui.osWindow.sizeDelta
template pixelDensityChanged*(gui: Gui): bool = gui.osWindow.pixelDensityChanged
template aspectRatio*(gui: Gui): float = gui.osWindow.aspectRatio
template gainedFocus*(gui: Gui): bool = gui.osWindow.gainedFocus
template lostFocus*(gui: Gui): bool = gui.osWindow.lostFocus
template mouseEntered*(gui: Gui): bool = gui.osWindow.mouseEntered
template mouseExited*(gui: Gui): bool = gui.osWindow.mouseExited

func backgroundColor*(gui: Gui): Color =
  gui.storedBackgroundColor

proc `backgroundColor=`*(gui: Gui, color: Color) =
  gui.osWindow.backgroundColor = color
  gui.storedBackgroundColor = color

proc newGui*(): Gui =
  result = Gui()
  result.osWindow = newOsWindow()
  result.renderer = newDrawListRenderer()
  result.gfx = newDrawList()

proc beginFrame*(gui: Gui) =
  gui.renderer.beginFrame(gui.sizePixels, gui.pixelDensity)
  gui.gfx.clearCommands()

proc endFrame*(gui: Gui) =
  gui.renderer.render(gui.gfx)
  gui.renderer.endFrame(gui.sizePixels)

template onFrame*(gui: Gui, code: untyped): untyped =
  gui.osWindow.onFrame = proc() =
    gui.beginFrame()
    code
    gui.endFrame()