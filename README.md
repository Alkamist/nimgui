# Nimgui
This library contains my experiments with gui logic. It doesn't really have a name yet so Nimgui is a placeholder.

### How it works
Here's a little demo of how to draw a red square:

```nim
import nimgui
import nimgui/backends

let gui = Gui.new()
gui.backgroundColor = rgb(49, 51, 56)
gui.setupBackend()
gui.show()

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  let path = Path.new()
  path.rect(vec2(50, 50), vec2(200, 200))
  gui.fillPath(path, rgb(255, 0, 0))

  gui.endFrame()

gui.run()
```

There's a fairly monolithic ref object named `Gui` that you work with, which comes from `import nimgui`. `Gui` provides the basic tools necessary to construct an immediate mode gui.

By default, it is platform agnostic, except that it is currently tied to using OpenGl. (It is not impossible to abstract that away, but it would be quite involved, and I don't have any reason to do so at the moment. It uses [Nanovg](https://github.com/memononen/nanovg) for vector graphics, and there is an OpenGl backend provided, but it should technically be possible to not rely on that.)

So anyway, `Gui` doesn't rely on a specific platform by default, that comes from `import nimgui/backends`. That import contains a few backend implementations I have written.

The only two platforms I currently know how to do from scratch and have access to a machine to test on are Windows and Emscripten, so those are provided, however I have written a GLFW backend using [staticglfw](https://github.com/treeform/staticglfw) as well for use on other platforms.

`import nimgui/backends` is optional, and also serves as an example of what writing a backend looks like.

If you want to use the Emscripten backend, you will need to copy `shell_minimal.html` and `config.nims` into your project directory. It can then be selected by passing in `-d:emscripten` during compilation.

### Input
`Gui` collects user input from the backend and provides ways to interact with it. Here are some examples:

```nim
if gui.mouseMoved: echo "Mouse moved: " & $gui.mousePosition
if gui.mousePressed(Left): echo "Mouse left pressed"
if gui.mouseReleased(Left): echo "Mouse left released"
if gui.keyPressed(Space): echo "Space key pressed"
if gui.keyReleased(Space): echo "Space key released"
if gui.mouseWheelMoved: echo "Mouse wheel moved: " & $gui.mouseWheel
if gui.textInput != "": echo "Text input: " & gui.textInput
```

There are many more functions, which can all be seen in `nimgui/gui.nim`. Currently input has been designed around using a desktop computer, however I would eventually like to figure out a way to nicely handle other forms of input like touch/mobile.

### Graphics
Graphical capabilities are fairly basic for now, but the general idea is that you create and describe a `Path` (see `nimgui/path.nim`), and then you can fill it or stroke it.

I have not yet implemented all possible path functions as I have not needed them, but it would be fairly trivial to do so. A Path is just a series of commands that get passed to Nanovg to handle.

There is another type of command called a `DrawCommand`. These are collected during the main loop and then rendered at the end of the frame. There are a number of functions in `nimgui/gui.nim` that can be used to queue up these commands.

Here is an example of the code I use to draw a button:

```nim
let path = Path.new()
path.roundedRect(button.position, button.size, 3)

gui.fillPath(path, rgb(31, 32, 34))

if button.isDown:
  gui.fillPath(path, rgba(0, 0, 0, 8))

elif gui.isHovered(button):
  gui.fillPath(path, rgba(255, 255, 255, 8))
```

There are some basic text capabilities as well. You must read in a font and then add it to the gui, then you can draw text like so:

```nim
import nimgui
import nimgui/backends

const fontData = readFile("your_font.ttf")

let gui = Gui.new()
gui.backgroundColor = rgb(49, 51, 56)
gui.setupBackend()
gui.addFont(fontData)
gui.show()

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  gui.fillTextLine("Hello World", gui.mousePosition)

  gui.endFrame()

gui.run()
```

Text editing and wordwrapping are things I want to try to tackle at some point.

### Widgets
In my current system, widgets are just ref objects and functions that utilize them and the `Gui`.

You can `import nimgui/widgets` to have access to some premade widgets I have written. They also can serve as an example of how to write widgets.

### Hover and MouseOver
User interaction with widgets is facilitated by the hover system. Only one widget can be hovered at a time.

You can use `gui.requestHover(widget)` to register with the gui that the widget wants to be hovered. At the end of the frame, the `Gui` will select the topmost widget as its current hover. You can then check `gui.isHovered(widget)` next frame to see if it is hovered and respond accordingly.

There is a small distinction between hover and mouseover, which is that a hover can be captured. When a hover is captured, the gui's hover is locked on that widget, and can only be released by that widget.

Here is a quick example:

```nim
import nimgui
import nimgui/backends

let gui = Gui.new()
gui.backgroundColor = rgb(49, 51, 56)
gui.setupBackend()
gui.show()

type
  MyWidget = ref object
    position: Vec2
    size: Vec2
    color: Color

proc update(gui: Gui, myWidget: MyWidget) =
  if gui.mouseHitTest(myWidget.position, myWidget.size):
    gui.requestHover(myWidget)

  let path = Path.new()
  path.rect(myWidget.position, myWidget.size)

  gui.fillPath(path, myWidget.color)
  if gui.isHovered(myWidget):
    gui.strokePath(path, rgb(255, 255, 255))

let widget1 = MyWidget.new()
widget1.position = vec2(50, 50)
widget1.size = vec2(300, 200)
widget1.color = rgb(128, 0, 0)

let widget2 = MyWidget.new()
widget2.position = vec2(100, 100)
widget2.size = vec2(400, 100)
widget2.color = rgb(0, 128, 0)

gui.onFrame = proc(gui: Gui) =
  gui.beginFrame()

  gui.update(widget1)
  gui.update(widget2)

  gui.endFrame()

gui.run()
```

`nimgui/widgets/button.nim` is another example of how all of this works.

### Tools
There are a number of tools implemented in `nimgui/gui.nim` to help with making widgets and behavior in general. There can surely be improvements but this is just what I have come up with for now. The tools are stack based, and can be utilized by using a `begin` and `end` pair.

#### Offsets:
`beginOffset` and `endOffset` can be used to positionally alter the behavior and drawing of code.

#### Clip rects:
`beginClipRect` and `endClipRect` can be used to visually and behaviorally clip the content of code.

#### Z index:
By default, graphical code is rendered in the order it is declared in control flow. The reason for collecting `DrawCommands` until the end of the frame is so that they can be reordered if desired. `beginZIndex` and `endZIndex` can be used for this purpose.

#### Interaction tracker:
This one's a little more niche but I needed something like this when I made `nimgui/widgets/window.nim`. Using `beginInteractionTracker` and `endInteractionTracker` you can track if any code in between was interacted with.

### Notes
There is still a lot to be done, and I change the way I am doing things often. This is by no means a complete and stable repository.