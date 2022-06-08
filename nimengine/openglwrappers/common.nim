import opengl

type
  BufferUsage* = enum
    StreamDraw = GL_STREAM_DRAW
    StreamRead = GL_STREAM_READ
    StreamCopy = GL_STREAM_COPY
    StaticDraw = GL_STATIC_DRAW
    StaticRead = GL_STATIC_READ
    StaticCopy = GL_STATIC_COPY
    DynamicDraw = GL_DYNAMIC_DRAW
    DynamicRead = GL_DYNAMIC_READ
    DynamicCopy = GL_DYNAMIC_COPY