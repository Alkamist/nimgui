import ../nimengine

const vertexShader = """
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 projection;
uniform mat4 camera;

void main()
{
  gl_Position = projection * camera * vec4(aPos, 1.0f);
  TexCoord = aTexCoord;
}
"""

const fragmentShader = """
#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D texture1;

void main()
{
  vec4 texColor = texture(texture1, TexCoord);
  FragColor = texColor;
}
"""

let w = Window.new()
w.makeContextCurrent()

gfx.init()
gfx.enableAlphaBlend()
gfx.enableDepthTesting()

var vertices = VertexBuffer[(array[3, float32], array[2, float32])].init()
vertices.uploadData [
  ([-0.5f, -0.5f, -0.5f], [0.0f, 0.0f]),
  ([0.5f, -0.5f, -0.5f], [1.0f, 0.0f]),
  ([0.5f,  0.5f, -0.5f], [1.0f, 1.0f]),
  ([-0.5f,  0.5f, -0.5f], [0.0f, 1.0f]),
  ([-0.5f, -0.5f,  0.5f], [1.0f, 0.0f]),
  ([0.5f, -0.5f,  0.5f], [0.0f, 0.0f]),
  ([0.5f,  0.5f,  0.5f], [0.0f, 1.0f]),
  ([-0.5f,  0.5f,  0.5f], [1.0f, 1.0f]),
]

var indices = IndexBuffer[uint32].init()
indices.uploadData [
  0'u32, 1, 2,
  2, 3, 0,

  4, 5, 6,
  6, 7, 4,

  7, 3, 0,
  0, 4, 7,

  6, 2, 1,
  1, 5, 6,

  0, 1, 5,
  5, 4, 0,

  3, 2, 6,
  6, 7, 3,
]

var texture = Texture.init(1, 1)
texture.loadFile("examples/barrel_side.png")
texture.uploadData()

var shader = Shader.init(vertexShader, fragmentShader)

var aspectRatio = w.client.width / w.client.height
var projection = perspective[float32](90.0, aspectRatio, 0.01, 1000.0)
shader.setUniform("projection", projection)

proc draw() =
  gfx.clearBackground()
  gfx.clearDepthBuffer()
  gfx.drawTriangles(shader, vertices, indices, texture)
  w.swapBuffers()

w.client.resizeListeners.add proc() =
  gfx.setViewport(0, 0, w.client.width.toInt, w.client.height.toInt)
  aspectRatio = w.client.width / w.client.height
  projection = perspective[float32](90.0, aspectRatio, 0.01, 1000.0)
  shader.setUniform("projection", projection)
  draw()

while not w.shouldClose:
  var camera = lookAt(vec3(0.0, 1.0, -2.0), vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))
  shader.setUniform("camera", camera)

  draw()

  w.pollEvents()