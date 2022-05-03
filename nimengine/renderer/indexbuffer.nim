import pkg/opengl
export opengl

import ./common

type
  IndexType* = uint8 | uint16 | uint32

  IndexKind* {.pure.} = enum
    UInt8
    UInt16
    UInt32

  IndexBuffer* = ref object
    kind*: IndexKind
    len*: int
    id*: GLuint

proc toIndexKind*(T: type IndexType): IndexKind =
  when T is uint8: IndexKind.UInt8
  elif T is uint16: IndexKind.UInt16
  elif T is uint32: IndexKind.UInt32

proc indexSize*(kind: IndexKind): int =
  case kind:
  of IndexKind.UInt8: 1
  of IndexKind.UInt16: 2
  of IndexKind.UInt32: 4

proc toGlEnum*(kind: IndexKind): GLenum =
  case kind:
  of IndexKind.UInt8: cGL_UNSIGNED_BYTE
  of IndexKind.UInt16: cGL_UNSIGNED_SHORT
  of IndexKind.UInt32: GL_UNSIGNED_INT

proc select*(buffer: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer.id)

proc unselect*(buffer: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

proc reset*(buffer: IndexBuffer) =
  buffer.len = 0

proc upload*[T: IndexType](buffer: IndexBuffer, usage: BufferUsage, data: openArray[T]) =
  if data.len == 0: return
  if buffer.kind != T.toIndexKind:
    raise newException(IOError, "Index buffer kind does not match data.")

  buffer.select()
  if buffer.len < data.len:
    buffer.len = data.len
    glBufferData(
      target = GL_ELEMENT_ARRAY_BUFFER,
      size = data.len * sizeof(T),
      data = nil,
      usage = usage.toGlEnum,
    )
  glBufferSubData(
    target = GL_ELEMENT_ARRAY_BUFFER,
    offset = 0,
    size = data.len * sizeof(T),
    data = data[0].unsafeAddr,
  )

proc `=destroy`*(buffer: var type IndexBuffer()[]) =
  glDeleteBuffers(1, buffer.id.addr)

proc newIndexBuffer*(kind: IndexKind): IndexBuffer =
  result = IndexBuffer(kind: kind)
  glGenBuffers(1, result.id.addr)