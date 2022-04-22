import pkg/opengl

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

proc toGlEnum*(kind: IndexKind): GLenum =
  case kind:
  of IndexKind.UInt8: cGL_UNSIGNED_BYTE
  of IndexKind.UInt16: cGL_UNSIGNED_SHORT
  of IndexKind.UInt32: GL_UNSIGNED_INT

proc select*(self: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.id)

proc unselect*(self: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

proc upload*[T: IndexType](self: var IndexBuffer, data: openArray[T]) =
  if data.len == 0: return
  if self.kind != T.toIndexKind:
    raise newException(IOError, "Index self kind does not match data.")

  self.len = data.len
  self.select()
  glBufferData(
    target = GL_ELEMENT_ARRAY_BUFFER,
    size = data.len * sizeof(T),
    data = data[0].unsafeAddr,
    usage = GL_STATIC_DRAW,
  )

proc `=destroy`*(self: var type IndexBuffer()[]) =
  glDeleteBuffers(1, self.id.addr)

proc newIndexBuffer*(kind: IndexKind): IndexBuffer =
  result = IndexBuffer(kind: kind)
  glGenBuffers(1, result.id.addr)