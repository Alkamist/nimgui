import pkg/opengl

import ./indexbuffer
import ./vertexbuffer
import ./shader
import ./texture
import ./types

var openGlIsLoaded = false

proc init*() =
  if not openGlIsLoaded:
    opengl.loadExtensions()
    openGlIsLoaded = true

proc setBackgroundColor*(color: ColorRgbaConcept) =
  glClearColor(color.r, color.g, color.b, color.a)

proc clearBackground*() =
  glClear(GL_COLOR_BUFFER_BIT)

proc clearDepthBuffer*() =
  glClear(GL_DEPTH_BUFFER_BIT)

proc enableAlphaBlend*() =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc enableDepthTesting*() =
  glEnable(GL_DEPTH_TEST)

proc setViewport*(x, y, width, height: int) =
  if width >= 0 and height >= 0:
    glViewport(
      x.GLsizei, y.GLsizei,
      width.GLsizei, height.GLsizei,
    )

proc drawTriangles*[V, I](shader: Shader,
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

proc drawTriangles*[V, I](shader: Shader,
                          vertices: VertexBuffer[V],
                          indices: IndexBuffer[I],
                          texture: Texture) =
  texture.select()
  drawTriangles(shader, vertices, indices)