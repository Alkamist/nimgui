import opengl
import ./common

type
  AttributeKind* = enum
    Float, Float2, Float3, Float4,
    Mat3, Mat4,
    Int, Int2, Int3, Int4,
    Bool,

  VertexBuffer* = ref object
    len*: int
    id*: GLuint
    m_layout: seq[AttributeKind]

func toGlEnum*(kind: AttributeKind): GLenum =
  case kind:
  of Float: cGL_FLOAT
  of Float2: cGL_FLOAT
  of Float3: cGL_FLOAT
  of Float4: cGL_FLOAT
  of Mat3: cGL_FLOAT
  of Mat4: cGL_FLOAT
  of Int: cGL_INT
  of Int2: cGL_INT
  of Int3: cGL_INT
  of Int4: cGL_INT
  of Bool: GL_BOOL

func valueCount*(kind: AttributeKind): int =
  case kind:
  of Float: 1
  of Float2: 2
  of Float3: 3
  of Float4: 4
  of Mat3: 9
  of Mat4: 16
  of Int: 1
  of Int2: 2
  of Int3: 3
  of Int4: 4
  of Bool: 1

func byteCount*(kind: AttributeKind): int =
  if kind == Bool:
    return 1
  kind.valueCount * 4

func byteCount*(layout: openArray[AttributeKind]): int =
  for kind in layout:
    result += kind.byteCount

proc select*(buffer: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, buffer.id)

proc unselect*(buffer: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, 0)

proc reset*(buffer: VertexBuffer) =
  buffer.len = 0

# This currently does not check to see if the data you are uploading
# matches the layout provided.
proc upload*[T](buffer: VertexBuffer, usage: BufferUsage, data: openArray[T]) =
  if data.len == 0: return
  buffer.select()
  if buffer.len < data.len:
    buffer.len = data.len
    glBufferData(
      target = GL_ARRAY_BUFFER,
      size = data.len * sizeof(T),
      data = nil,
      usage = usage.GlEnum,
    )
  glBufferSubData(
    target = GL_ARRAY_BUFFER,
    offset = 0,
    size = data.len * sizeof(T),
    data = data[0].unsafeAddr,
  )

proc uploadLayout(buffer: VertexBuffer) =
  let vertexByteCount = buffer.m_layout.byteCount
  var byteOffset = 0
  buffer.select()

  for i, attribute in buffer.m_layout:
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

proc layout*(buffer: VertexBuffer): seq[AttributeKind] =
  buffer.m_layout

proc setLayout*(buffer: VertexBuffer, layout: openArray[AttributeKind]) =
  buffer.m_layout = newSeq[AttributeKind](layout.len)
  for i, attribute in layout:
    buffer.m_layout[i] = attribute
  buffer.uploadLayout()

proc `=destroy`*(buffer: var type VertexBuffer()[]) =
  glDeleteBuffers(1, buffer.id.addr)

proc newVertexBuffer*(layout: openArray[AttributeKind]): VertexBuffer =
  result = VertexBuffer()
  glGenBuffers(1, result.id.addr)
  result.setLayout(layout)