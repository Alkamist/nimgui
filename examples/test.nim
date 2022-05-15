{.experimental: "overloadableEnums".}

import nimengine

let client = newClient()

let openGlContext = gfx.newOpenGlContext(client.handle)

gfx.setBackgroundColor(0.0, 0.4, 0.0, 1.0)

client.onFrame = proc() =
  gfx.setViewport(0.0, 0.0, client.size.x.float, client.size.y.float)
  gfx.clearBackground()

  openGlContext.swapBuffers()

  if client.mouseMoved:
    echo client.mousePosition

while client.isOpen:
  client.update()