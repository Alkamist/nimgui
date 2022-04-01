import pkg/opengl
export opengl

import gfx/indexbuffer
import gfx/shader
import gfx/texture
import gfx/types
import gfx/vertexbuffer

export indexbuffer
export shader
export texture
export types
export vertexbuffer

type
  Gfx* = ref object

var openGlIsLoaded = false

proc init*(_: type Gfx): Gfx =
  if not openGlIsLoaded:
    when not defined(emscripten):
      opengl.loadExtensions()
    openGlIsLoaded = true
  Gfx()

proc setBackgroundColor*(gfx: Gfx, color: ColorRgbaConcept) =
  glClearColor(color.r, color.g, color.b, color.a)

proc clearBackground*(gfx: Gfx) =
  glClear(GL_COLOR_BUFFER_BIT)

proc clearDepthBuffer*(gfx: Gfx) =
  glClear(GL_DEPTH_BUFFER_BIT)

proc enableAlphaBlend*(gfx: Gfx) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc enableDepthTesting*(gfx: Gfx) =
  glEnable(GL_DEPTH_TEST)

proc setViewport*(gfx: Gfx, x, y, width, height: int) =
  if width >= 0 and height >= 0:
    glViewport(
      x.GLsizei, y.GLsizei,
      width.GLsizei, height.GLsizei,
    )

proc drawTriangles*[V, I](gfx: Gfx,
                          shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I]) =
  shader.select()
  vertices.selectLayout()
  indices.select()
  glDrawElements(
    GL_TRIANGLES,
    indices.len.GLsizei,
    indices.typeToGlEnum,
    nil
  )

proc drawTriangles*[V, I](gfx: Gfx,
                          shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I],
                          texture: Texture) =
  texture.select()
  gfx.drawTriangles(shader, vertices, indices)