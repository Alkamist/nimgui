import ./types

const vertexShader2d = """
#version 300 es
precision highp float;
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;
out vec2 TexCoord;
void main()
{
  gl_Position = vec4(aPos, 1.0f);
  TexCoord = aTexCoord;
}
"""

const fragmentShader2d = """
#version 300 es
precision highp float;
out vec4 FragColor;
in vec2 TexCoord;
uniform sampler2D texture1;
void main()
{
  vec4 texColor = texture(texture1, TexCoord);
  FragColor = texColor;
}
"""

proc setupGraphics*(window: Window) =
  window.gfxCtx = newGfxContext(window.platform.handle)
  window.gfxCtx.enableAlphaBlend()

  window.quadVertexBuffer = initVertexBuffer([VertexAttributeKind.Float3,
                                              VertexAttributeKind.Float2])
  window.quadVertexBuffer.uploadData [
    ([-1f, -1f, 0f], [0.0f, 0.0f]),
    ([1f, -1f, 0f], [1.0f, 0.0f]),
    ([1f, 1f, 0f], [1.0f, 1.0f]),
    ([-1f, 1f, 0f], [0.0f, 1.0f]),
  ]

  window.quadIndexBuffer = initIndexBuffer(IndexKind.UInt32)
  window.quadIndexBuffer.uploadData([
    0'u32, 1, 3,
    1, 3, 2,
  ])

  window.quadShader = initShader(vertexShader2d, fragmentShader2d)
  window.quadTexture = initTexture()

  window.ctx = newContext(1, 1)

proc processMouseMove*(window: Window, x, y: float) =
  if window.mouseX == x and window.mouseY == y:
    return

  window.previousMouseX = window.mouseX
  window.previousMouseY = window.mouseY
  window.mouseX = x
  window.mouseY = y
  window.mouseXChange = window.mouseX - window.previousMouseX
  window.mouseYChange = window.mouseY - window.previousMouseY

  if window.onMouseMove != nil:
    window.onMouseMove(window)

proc processMouseEnter*(window: Window) =
  window.cursorIsOver = true
  if window.onMouseEnter != nil:
    window.onMouseEnter(window)

proc processMouseExit*(window: Window) =
  window.cursorIsOver = false
  if window.onMouseExit != nil:
    window.onMouseExit(window)

proc processMouseWheel*(window: Window, x, y: float) =
  window.mouseWheelX = x
  window.mouseWheelY = y
  if window.onMouseWheel != nil:
    window.onMouseWheel(window)

proc processMousePress*(window: Window, button: MouseButton) =
  window.mousePress = button
  window.mouseButtonStates[button] = true
  if window.onMousePress != nil:
    window.onMousePress(window)

proc processMouseRelease*(window: Window, button: MouseButton) =
  window.mouseRelease = button
  window.mouseButtonStates[button] = false
  if window.onMouseRelease != nil:
    window.onMouseRelease(window)

proc processKeyPress*(window: Window, key: KeyboardKey) =
  window.keyPress = key
  window.keyStates[key] = true
  if window.onKeyPress != nil:
    window.onKeyPress(window)

proc processKeyRelease*(window: Window, key: KeyboardKey) =
  window.keyRelease = key
  window.keyStates[key] = false
  if window.onKeyRelease != nil:
    window.onKeyRelease(window)

proc processCharacter*(window: Window, character: string) =
  window.character = character
  if window.onCharacter != nil:
    window.onCharacter(window)

proc processClose*(window: Window) =
  if window.onClose != nil:
    window.onClose(window)

proc processFocus*(window: Window) =
  if window.onFocus != nil:
    window.onFocus(window)

proc processLoseFocus*(window: Window) =
  if window.onLoseFocus != nil:
    window.onLoseFocus(window)

proc processMove*(window: Window, x, y: float) =
  window.previousX = window.x
  window.previousY = window.y
  window.x = x
  window.y = y
  window.xChange = window.x - window.previousX
  window.yChange = window.y - window.previousY
  if window.onMove != nil:
    window.onMove(window)

proc processResize*(window: Window, width, height: float) =
  window.previousWidth = window.width
  window.previousHeight = window.height
  window.width = width
  window.height = height
  window.widthChange = window.width - window.previousWidth
  window.heightChange = window.height - window.previousHeight

  let w = window.width.int.max(1)
  let h = window.height.int.max(1)
  window.ctx.image.width = w
  window.ctx.image.height = h
  window.ctx.image.data.setLen(w * h)
  window.ctx.image.fill(rgba(0, 0, 0, 0))

  if window.onResize != nil:
    window.onResize(window)

  window.gfxCtx.select()
  window.gfxCtx.setViewport(0, 0, window.width.int, window.height.int)
  window.gfxCtx.clearBackground()

  if window.render != nil:
    window.render(window)

  window.quadTexture.uploadData(window.ctx.image)
  window.gfxCtx.drawTriangles(
    window.quadShader,
    window.quadVertexBuffer,
    window.quadIndexBuffer,
    window.quadTexture,
  )
  window.gfxCtx.swapBuffers()
  window.gfxCtx.unselect()