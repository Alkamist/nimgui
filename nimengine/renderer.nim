import pkg/opengl
export opengl

import ./window
import ./renderer/platformcontext
import ./renderer/indexbuffer
import ./renderer/vertexBuffer
import ./renderer/shader
import ./renderer/texture

export indexbuffer
export vertexBuffer
export shader
export texture

# const vertexShader2d = """
# #version 300 es
# precision highp float;
# layout (location = 0) in vec2 Position;
# layout (location = 1) in vec2 UV;
# layout (location = 2) in vec4 Color;
# uniform mat4 ProjMtx;
# out vec2 Frag_UV;
# out vec4 Frag_Color;
# void main()
# {
#     Frag_UV = UV;
#     Frag_Color = Color;
#     gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
# }
# """

# const fragmentShader2d = """
# #version 300 es
# precision mediump float;
# uniform sampler2D Texture;
# in vec2 Frag_UV;
# in vec4 Frag_Color;
# layout (location = 0) out vec4 Out_Color;
# void main()
# {
#     Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
# }
# """

const vertexShader2d = """
#version 300 es
precision highp float;
layout (location = 0) in vec2 Position;
layout (location = 1) in vec4 Color;
uniform mat4 ProjMtx;
out vec4 Frag_Color;
void main()
{
    Frag_Color = Color;
    gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
}
"""

const fragmentShader2d = """
#version 300 es
precision mediump float;
in vec4 Frag_Color;
layout (location = 0) out vec4 Out_Color;
void main()
{
    Out_Color = Frag_Color;
}
"""

proc orthoProjection(left, right, top, bottom: float32): array[4, array[4, float32]] =
  [
    [2.0f / (right - left), 0.0f, 0.0f, 0.0f],
    [0.0f, 2.0f / (top - bottom), 0.0f, 0.0f],
    [0.0f, 0.0f, -1.0f, 0.0f],
    [(right + left) / (left - right), (top + bottom) / (bottom - top), 0.0f, 1.0f],
  ]

const bufferSize = 2048

type
  Vertex2d = object
    x, y: float32
    r, g, b, a: float32

  Renderer* = ref object
    window*: Window
    onRender*: proc()
    platformContext: PlatformContext
    shader2d: Shader
    vertexBuffer2d: VertexBuffer
    indexBuffer2d: IndexBuffer
    vertexBufferData2d: array[bufferSize, Vertex2d]
    indexBufferData2d: array[bufferSize, uint32]

proc newRenderer*(window: Window): Renderer =
  result = Renderer()
  result.window = window
  result.platformContext = initPlatformContext(window.platform.handle)
  result.shader2d = initShader(vertexShader2d, fragmentShader2d)
  result.vertexBuffer2d = initVertexBuffer([VertexAttributeKind.Float2,
                                            VertexAttributeKind.Float4])
  result.indexBuffer2d = initIndexBuffer(IndexKind.UInt32)

proc clear*(self: Renderer, r, g, b, a: float) =
  glClearColor(r.GLfloat, g.GLfloat, b.GLfloat, a.GLfloat)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc drawTriangles*(self: Renderer,
                    shader: Shader,
                    vertices: VertexBuffer,
                    indices: IndexBuffer) =
  shader.select()
  vertices.select()
  indices.select()
  glDrawElements(
    GL_TRIANGLES,
    indices.len.GLsizei,
    indices.kind.toGlEnum,
    nil
  )

proc drawTriangles*(self: Renderer,
                    shader: Shader,
                    vertices: VertexBuffer,
                    indices: IndexBuffer,
                    texture: Texture) =
  texture.select()
  self.drawTriangles(shader, vertices, indices)

proc setupBaseRenderState(self: Renderer) =
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)
  glActiveTexture(GL_TEXTURE0)

proc setupRenderState2d(self: Renderer) =
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

# proc setupRenderState3d(self: Renderer) =
#   # glEnable(GL_CULL_FACE)
#   glEnable(GL_DEPTH_TEST)

proc resize(self: Renderer, x, y, w, h: float) =
  if w >= 0 and h >= 0:
    glViewport(x.GLsizei, y.GLsizei,
               w.GLsizei, h.GLsizei)
    glScissor(x.GLsizei, y.GLsizei,
              w.GLsizei, h.GLsizei)

proc render*(self: Renderer) =
  let w = self.window.width
  let h = self.window.height

  self.setupBaseRenderState()
  self.resize(0, 0, w, h)

  self.setupRenderState2d()

  if self.onRender != nil:
    self.onRender()

  self.shader2d.setUniform("ProjMtx", orthoProjection(0, 0, w, h))
  self.vertexBuffer2d.uploadData(self.vertexBufferData2d)
  self.indexBuffer2d.uploadData(self.indexBufferData2d)
  self.drawTriangles(self.shader2d, self.vertexBuffer2d, self.indexBuffer2d)

  # self.setupRenderState3d()

  self.platformContext.swapBuffers()