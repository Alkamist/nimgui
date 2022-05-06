import pkg/opengl
export opengl

import ../gmath
export gmath

import ./indexbuffer
export indexbuffer

{.push inline.}

proc enableBlend*() =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc disableBlend*() =
  glDisable(GL_BLEND)

proc enableClipping*() =
  glEnable(GL_SCISSOR_TEST)

proc disableClipping*() =
  glDisable(GL_SCISSOR_TEST)

proc enableFaceCulling*() =
  glEnable(GL_CULL_FACE)

proc disableFaceCulling*() =
  glDisable(GL_CULL_FACE)

proc enableDepthTesting*() =
  glEnable(GL_DEPTH_TEST)

proc disableDepthTesting*() =
  glDisable(GL_DEPTH_TEST)

proc setBackgroundColor*(r, g, b, a: float) =
  glClearColor(r, g, b, a)

proc setBackgroundColor*(color: Color) =
  glClearColor(color.r, color.g, color.b, color.a)

proc clearBackground*() =
  glClear(GL_COLOR_BUFFER_BIT)

proc setViewport*(x, y, width, height: float) =
  glViewport(x.GLint, y.GLint, width.GLsizei, height.GLsizei)

proc setClipRect*(x, y, width, height: float) =
  glScissor(x.GLint, y.GLint, width.GLsizei, height.GLsizei)

proc drawTriangles*(indexCount: int, indexKind: IndexKind, indexOffset: int) =
  glDrawElements(
    GL_TRIANGLES,
    indexCount.GLsizei,
    indexKind.toGlEnum,
    cast[pointer](indexOffset * indexKind.indexSize),
  )

{.pop.}