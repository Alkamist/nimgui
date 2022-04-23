import pkg/opengl

type
  VertexAttributeKind* {.pure.} = enum
    Float, Float2, Float3, Float4,
    Mat3, Mat4,
    Int, Int2, Int3, Int4,
    Bool,

  VertexBuffer* = ref object
    len*: int
    id*: GLuint
    m_layout: seq[VertexAttributeKind]

func toGlEnum*(kind: VertexAttributeKind): GLenum =
  case kind:
  of VertexAttributeKind.Float: cGL_FLOAT
  of VertexAttributeKind.Float2: cGL_FLOAT
  of VertexAttributeKind.Float3: cGL_FLOAT
  of VertexAttributeKind.Float4: cGL_FLOAT
  of VertexAttributeKind.Mat3: cGL_FLOAT
  of VertexAttributeKind.Mat4: cGL_FLOAT
  of VertexAttributeKind.Int: cGL_INT
  of VertexAttributeKind.Int2: cGL_INT
  of VertexAttributeKind.Int3: cGL_INT
  of VertexAttributeKind.Int4: cGL_INT
  of VertexAttributeKind.Bool: GL_BOOL

func valueCount*(kind: VertexAttributeKind): int =
  case kind:
  of VertexAttributeKind.Float: 1
  of VertexAttributeKind.Float2: 2
  of VertexAttributeKind.Float3: 3
  of VertexAttributeKind.Float4: 4
  of VertexAttributeKind.Mat3: 9
  of VertexAttributeKind.Mat4: 16
  of VertexAttributeKind.Int: 1
  of VertexAttributeKind.Int2: 2
  of VertexAttributeKind.Int3: 3
  of VertexAttributeKind.Int4: 4
  of VertexAttributeKind.Bool: 1

func byteCount*(kind: VertexAttributeKind): int =
  if kind == VertexAttributeKind.Bool:
    return 1
  kind.valueCount * 4

func byteCount*(layout: openArray[VertexAttributeKind]): int =
  for kind in layout:
    result += kind.byteCount

proc select*(self: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, self.id)

proc unselect*(self: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, 0)

# This currently does not check to see if the data you are uploading
# matches the layout provided.
proc upload*[T](self: VertexBuffer, data: openArray[T]) =
  if data.len == 0: return
  self.len = data.len
  self.select()
  glBufferData(
    target = GL_ARRAY_BUFFER,
    size = data.len * T.sizeof,
    data = data[0].unsafeAddr,
    usage = GL_STATIC_DRAW,
  )

proc uploadLayout(self: VertexBuffer) =
  let vertexByteCount = self.m_layout.byteCount
  var byteOffset = 0
  self.select()

  for i, attribute in self.m_layout:
    glEnableVertexAttribArray(i.GLuint)
    glVertexAttribPointer(
      index = i.GLuint, # the 0 based index of the attribute
      size = attribute.valueCount.GLint, # the number of values in the attribute
      `type` = attribute.toGlEnum, # the type of value present in the attribute
      normalized = GL_FALSE, # normalize the values from 0 to 1 on the gpu
      stride = vertexByteCount.GLsizei, # byte offset of each vertex
      `pointer` = cast[pointer](byteOffset), # byte offset of the start of the attribute, cast as a pointer
    )
    byteOffset += attribute.byteCount

proc layout*(self: VertexBuffer): seq[VertexAttributeKind] =
  self.m_layout

proc setLayout*(self: VertexBuffer, layout: openArray[VertexAttributeKind]) =
  self.m_layout = newSeq[VertexAttributeKind](layout.len)
  for i, attribute in layout:
    self.m_layout[i] = attribute
  self.uploadLayout()

proc `=destroy`*(self: var type VertexBuffer()[]) =
  glDeleteBuffers(1, self.id.addr)

proc newVertexBuffer*(layout: openArray[VertexAttributeKind]): VertexBuffer =
  result = VertexBuffer()
  glGenBuffers(1, result.id.addr)
  result.setLayout(layout)