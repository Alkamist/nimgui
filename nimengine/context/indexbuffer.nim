import pkg/opengl

type
  IndexType* = uint8 | uint16 | uint32

  IndexBuffer*[T: IndexType] = object
    len*: int
    id*: GLuint

proc typeToGlEnum*[T: IndexType](buffer: IndexBuffer[T]): GLenum =
  when T is uint8: result = cGL_UNSIGNED_BYTE
  elif T is uint16: result = cGL_UNSIGNED_SHORT
  elif T is uint32: result = GL_UNSIGNED_INT

proc select*(buffer: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer.id)

proc unselect*(buffer: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

proc uploadData*[T: IndexType](buffer: var IndexBuffer[T], data: openArray[T]) =
  var dataSeq = newSeq[T](data.len)
  for i, v in data:
    dataSeq[i] = v

  buffer.len = data.len
  buffer.select()

  glBufferData(
    target = GL_ELEMENT_ARRAY_BUFFER,
    size = dataSeq.len * sizeof(T),
    data = dataSeq[0].addr,
    usage = GL_STATIC_DRAW,
  )

proc `=destroy`*[T: IndexType](buffer: var IndexBuffer[T]) =
  glDeleteBuffers(1, buffer.id.addr)

proc init*[T: IndexType](_: type IndexBuffer[T]): IndexBuffer[T] =
  glGenBuffers(1, result.id.addr)