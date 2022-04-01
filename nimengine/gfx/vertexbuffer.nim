import std/macros
import pkg/opengl

type
  VertexAttributeKind* {.pure.} = enum
    Float32, Float64,
    UInt8, UInt16, UInt32,
    Int8, Int16, Int32,

  VertexAttribute* = object
    kind*: VertexAttributeKind
    valueCount*: int

  VertexBuffer*[T: tuple] = object
    len*: int
    id*: GLuint

proc toGlEnum*(attributeKind: VertexAttributeKind): GLenum =
  case attributeKind:
  of VertexAttributeKind.Float32: cGL_FLOAT
  of VertexAttributeKind.Float64: cGL_DOUBLE
  of VertexAttributeKind.UInt32: GL_UNSIGNED_INT
  of VertexAttributeKind.UInt16: cGL_UNSIGNED_SHORT
  of VertexAttributeKind.UInt8: cGL_UNSIGNED_BYTE
  of VertexAttributeKind.Int32: cGL_INT
  of VertexAttributeKind.Int16: cGL_SHORT
  of VertexAttributeKind.Int8: cGL_BYTE

proc byteCount*(attributeKind: VertexAttributeKind): int =
  case attributeKind:
  of VertexAttributeKind.Float32: 4
  of VertexAttributeKind.Float64: 8
  of VertexAttributeKind.UInt32: 4
  of VertexAttributeKind.UInt16: 2
  of VertexAttributeKind.UInt8: 1
  of VertexAttributeKind.Int32: 4
  of VertexAttributeKind.Int16: 2
  of VertexAttributeKind.Int8: 1

proc byteCount*(attribute: VertexAttribute): int =
  attribute.valueCount * attribute.kind.byteCount

proc toVertexAttributeKind*(n: NimNode): VertexAttributeKind =
  case n.typeKind:
  of ntyFloat32: result = VertexAttributeKind.Float32
  of ntyFloat64: result = VertexAttributeKind.Float64
  of ntyUint32: result = VertexAttributeKind.UInt32
  of ntyUint16: result = VertexAttributeKind.UInt16
  of ntyUint8: result = VertexAttributeKind.UInt8
  of ntyInt32: result = VertexAttributeKind.Int32
  of ntyInt16: result = VertexAttributeKind.Int16
  of ntyInt8: result = VertexAttributeKind.Int8
  else: error "Unsupported vertex attribute type."

macro getAttributes*(vertexTypeDesc: typedesc): untyped =
  var vertexType = vertexTypeDesc.getType[1]
  var attributeCount = vertexType.len
  var attributes: seq[NimNode]

  for i in 1 ..< attributeCount:
    var attributeType = vertexType[i]

    if attributeType.typeKind == ntyArray:
      var arrayRangeHigh = attributeType[1][2]
      var attributeKind = attributeType[2].toVertexAttributeKind
      attributes.add quote do:
        VertexAttribute(kind: `attributeKind`.VertexAttributeKind, valueCount: `arrayRangeHigh` + 1)

    else:
      raise newException(IOError, "Unsupported type for vertex attribute.")

  result = nnkBracket.newTree()
  for attribute in attributes:
    result.add attribute

proc select*(buffer: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, buffer.id)

proc unselect*(buffer: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, 0)

proc uploadData*[T](buffer: var VertexBuffer[T], data: openArray[T]) =
  var dataSeq = newSeq[T](data.len)
  for i, v in data:
    dataSeq[i] = v

  buffer.len = data.len
  buffer.select()

  glBufferData(
    target = GL_ARRAY_BUFFER,
    size = dataSeq.len * T.sizeof,
    data = dataSeq[0].addr,
    usage = GL_STATIC_DRAW,
  )

proc selectLayout*[T](buffer: VertexBuffer[T]) =
  let vertexBytes = T.sizeof.GLsizei
  var byteOffset = 0
  buffer.select()

  for i, attribute in T.getAttributes:
    glEnableVertexAttribArray(i.GLuint)
    glVertexAttribPointer(
      index = i.GLuint,
        # the 0 based index of the attribute
      size = attribute.valueCount.GLint,
        # the number of values in the attribute
      `type` = attribute.kind.toGlEnum,
        # the type of value present in the attribute
      normalized = GL_FALSE,
        # normalize the values from 0 to 1 on the gpu
      stride = vertexBytes,
        # byte offset of each vertex
      `pointer` = cast[pointer](byteOffset),
        # byte offset of the start of the attribute, cast as a pointer
    )
    byteOffset += attribute.byteCount

proc `=destroy`*[T](buffer: var VertexBuffer[T]) =
  glDeleteBuffers(1, buffer.id.addr)

proc init*[T](_: type VertexBuffer[T]): VertexBuffer[T] =
  glGenBuffers(1, result.id.addr)