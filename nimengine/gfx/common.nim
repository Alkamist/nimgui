import pkg/opengl
export opengl

type
  BufferUsage* = enum
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
  of StreamDraw: GL_STREAM_DRAW
  of StreamRead: GL_STREAM_READ
  of StreamCopy: GL_STREAM_COPY
  of StaticDraw: GL_STATIC_DRAW
  of StaticRead: GL_STATIC_READ
  of StaticCopy: GL_STATIC_COPY
  of DynamicDraw: GL_DYNAMIC_DRAW
  of DynamicRead: GL_DYNAMIC_READ
  of DynamicCopy: GL_DYNAMIC_COPY