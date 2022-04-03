import pkg/opengl

type
  TextureColorConcept* = concept c
    c.r is uint8
    c.g is uint8
    c.b is uint8
    c.a is uint8

  TextureDataConcept* = concept t
    t.width is int
    t.height is int
    t.data is seq[TextureColorConcept]

  MinifyFilter* {.pure.} = enum
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR,
    NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
    LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
    NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,
    LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR,

  MagnifyFilter* {.pure.} = enum
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR,

  WrapMode* {.pure.} = enum
    Repeat = GL_REPEAT,
    ClampToBorder = GL_CLAMP_TO_BORDER,
    ClampToEdge = GL_CLAMP_TO_EDGE,
    MirroredRepeat = GL_MIRRORED_REPEAT,
    MirrorClampToEdge = GL_MIRROR_CLAMP_TO_EDGE,

  Texture* = object
    id*: GLuint

proc select*(texture: Texture) =
  glBindTexture(GL_TEXTURE_2D, texture.id)

proc setMinifyFilter*(texture: Texture, filter: MinifyFilter) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter.GLint)

proc setMagnifyFilter*(texture: Texture, filter: MagnifyFilter) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter.GLint)

proc setWrapS*(texture: Texture, mode: WrapMode) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode.GLint)

proc setWrapT*(texture: Texture, mode: WrapMode) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode.GLint)

proc setWrapR*(texture: Texture, mode: WrapMode) =
  texture.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, mode.GLint)

proc uploadData*(texture: Texture, textureData: var TextureDataConcept) =
  texture.select()
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA.GLint,
    textureData.width.Glsizei,
    textureData.height.Glsizei,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    textureData.data[0].addr,
  )

proc generateMipmap*(texture: Texture) =
  texture.select()
  glGenerateMipmap(GL_TEXTURE_2D)

proc init*(_: type Texture): Texture =
  result = Texture()
  glGenTextures(1, result.id.addr)
  result.setMinifyFilter(MinifyFilter.Nearest)
  result.setMagnifyFilter(MagnifyFilter.Nearest)
  result.setWrapS(WrapMode.Repeat)
  result.setWrapT(WrapMode.Repeat)