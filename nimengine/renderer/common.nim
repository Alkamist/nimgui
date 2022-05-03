import pkg/opengl
export opengl

type
  BufferUsage* {.pure.} = enum
    StreamDraw
    StreamRead
    StreamCopy
    StaticDraw
    StaticRead
    StaticCopy
    DynamicDraw
    DynamicRead
    DynamicCopy

func toGlEnum*(kind: BufferUsage): GLenum =
  case kind:
  of BufferUsage.StreamDraw: GL_STREAM_DRAW
  of BufferUsage.StreamRead: GL_STREAM_READ
  of BufferUsage.StreamCopy: GL_STREAM_COPY
  of BufferUsage.StaticDraw: GL_STATIC_DRAW
  of BufferUsage.StaticRead: GL_STATIC_READ
  of BufferUsage.StaticCopy: GL_STATIC_COPY
  of BufferUsage.DynamicDraw: GL_DYNAMIC_DRAW
  of BufferUsage.DynamicRead: GL_DYNAMIC_READ
  of BufferUsage.DynamicCopy: GL_DYNAMIC_COPY