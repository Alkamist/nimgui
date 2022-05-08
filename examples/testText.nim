{.experimental: "overloadableEnums".}

import pkg/nimengine
import pkg/nimengine/gmath/types

let window = newWindow()

let openGlContext = newOpenGlContext(window.platform.handle)
openGlContext.select()

gfx.enableBlend()
gfx.setBackgroundColor(rgb(32, 32, 32))

let canvas = newCanvas()
let canvasRenderer = newCanvasRenderer(canvas)

var size = vec2(128, 128)

# let textTemplate = "The quick brown fox.\n"
# var text = ""
# for i in 0 ..< 100:
#   text.add(textTemplate[i mod textTemplate.len])
let text = """void r_draw_text(const char *text, mu_Vec2 pos, mu_Color color) {
  mu_Rect dst = { pos.x, pos.y, 0, 0 };
  for (const char *p = text; *p; p++) {
    if ((*p & 0xc0) == 0x80) { continue; }
    int chr = mu_min((unsigned char) *p, 127);
    mu_Rect src = atlas[ATLAS_FONT + chr];
    dst.w = src.w;
    dst.h = src.h;
    push_quad(dst, src, color);
    dst.x += dst.w;
  }
}"""

proc render() =
  gfx.setViewport(0, 0, window.width, window.height)
  gfx.setClipRect(0, 0, window.width, window.height)
  gfx.clearBackground()

  canvas.beginFrame(window.width, window.height)

  canvas.fillRect(128, 128, size.x, size.y, rgb(120, 0, 0))
  canvas.drawText(text, rect2(128, 128, size.x, size.y), rgb(255, 255, 255), Left, Center)

  canvasRenderer.render()

  openGlContext.swapBuffers()

window.onResize = render

while not window.isClosed:
  window.pollEvents()

  if window.input.mouseDown[Left]:
    size.x = (window.input.mouseX - 128).max(0.0)
    size.y = (window.input.mouseY - 128).max(0.0)

  render()