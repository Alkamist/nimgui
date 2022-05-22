{.experimental: "overloadableEnums".}

# import std/math
import nimengine

let client = newClient()

let openGlContext = gfx.newOpenGlContext(client.handle)
openGlContext.select()

gfx.enableStencilTesting()
gfx.setBackgroundColor(0, 0.6, 0, 1)

nvgInit(openGlContext.getProcAddress)

var vg = nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES)

let consola = nvgCreateFont(vg, "normal", "./examples/consola.ttf")
if consola == -1:
  echo "Could not load consola.ttf."

proc drawWindow(vg: ptr NVGcontext, title: cstring, x, y, w, h: cfloat) =
  let cornerRadius = 3.0
  var shadowPaint: NVGpaint
  var headerPaint: NVGpaint

  nvgSave(vg)

  # Window
  nvgBeginPath(vg)
  nvgRoundedRect(vg, x, y, w, h, cornerRadius)
  nvgFillColor(vg, nvgRGBA(28, 30, 34, 192))
  nvgFill(vg)

  # Drop shadow
  shadowPaint = nvgBoxGradient(vg, x, y + 2, w, h, cornerRadius * 2, 10, nvgRGBA(0, 0, 0, 128), nvgRGBA(0, 0, 0, 0))
  nvgBeginPath(vg)
  nvgRect(vg, x - 10, y - 10, w + 20, h + 30)
  nvgRoundedRect(vg, x, y, w, h, cornerRadius)
  nvgPathWinding(vg, NVG_HOLE)
  nvgFillPaint(vg, shadowPaint)
  nvgFill(vg)

  # Header
  headerPaint = nvgLinearGradient(vg, x, y, x, y + 15, nvgRGBA(255, 255, 255, 8), nvgRGBA(0, 0, 0, 16))
  nvgBeginPath(vg)
  nvgRoundedRect(vg, x + 1, y + 1, w - 2, 30, cornerRadius - 1)
  nvgFillPaint(vg, headerPaint)
  nvgFill(vg)
  nvgBeginPath(vg)
  nvgMoveTo(vg, x + 0.5, y + 0.5 + 30)
  nvgLineTo(vg, x + 0.5 + w - 1, y + 0.5 + 30)
  nvgStrokeColor(vg, nvgRGBA(0, 0, 0, 32))
  nvgStroke(vg)

  nvgFontSize(vg, 15.0)
  nvgFontFace(vg, "normal")
  nvgTextAlign(vg, NVG_ALIGN_CENTER or NVG_ALIGN_MIDDLE)

  nvgFontBlur(vg, 2)
  nvgFillColor(vg, nvgRGBA(0, 0, 0, 128))
  discard nvgText(vg, x + w / 2, y + 16 + 1, title, nil)

  nvgFontBlur(vg, 0)
  nvgFillColor(vg, nvgRGBA(220, 220, 220, 160))
  discard nvgText(vg, x + w / 2, y + 16, title, nil)

  nvgRestore(vg)

proc onFrame() =
  if client.mouseDown(Middle):
    let zoomPull = client.mouseDeltaPixels.dot(vec2(1, 1).normalize)
    client.dpi *= 2.0.pow(zoomPull * 0.005)
    client.dpi = client.dpi.clamp(96.0, 5000.0)

  gfx.setViewport(0, 0, client.sizePixels.x, client.sizePixels.y)
  gfx.setClipRect(0, 0, client.sizePixels.x, client.sizePixels.y)
  gfx.clearBackground()
  gfx.clearStencilBuffer()

  nvgBeginFrame(vg, client.size.x, client.size.y, client.scale)

  drawWindow(vg, "Ayy Lmao", 100, 100, 400, 600)

  # nvgBeginPath(vg)
  # nvgFillColor(vg, nvgRGBAf(0.7, 0.7, 0.7, 1.0))
  # nvgFill(vg)

  nvgEndFrame(vg)

  openGlContext.swapBuffers()

client.onFrame = onFrame

while client.isOpen:
  client.update()