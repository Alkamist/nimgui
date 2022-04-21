import pkg/opengl
import ./concepts

type
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
    width*, height*: int

proc select*(self: Texture) =
  glBindTexture(GL_TEXTURE_2D, self.id)

proc setMinifyFilter*(self: Texture, filter: MinifyFilter) =
  self.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter.GLint)

proc setMagnifyFilter*(self: Texture, filter: MagnifyFilter) =
  self.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter.GLint)

proc setWrapS*(self: Texture, mode: WrapMode) =
  self.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mode.GLint)

proc setWrapT*(self: Texture, mode: WrapMode) =
  self.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mode.GLint)

proc setWrapR*(self: Texture, mode: WrapMode) =
  self.select()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, mode.GLint)

proc upload*(self: var Texture, image: SomeImage) =
  self.width = image.width
  self.height = image.height
  self.select()
  glTexImage2D(
    target = GL_TEXTURE_2D,
    level = 0,
    internalformat = GL_RGBA.GLint,
    width = image.width.GLsizei,
    height = image.height.GLsizei,
    border = 0,
    format = GL_RGBA,
    `type` = GL_UNSIGNED_BYTE,
    pixels = image.data[0].unsafeAddr,
  )

proc generateMipmap*(self: Texture) =
  self.select()
  glGenerateMipmap(GL_TEXTURE_2D)

proc initTexture*(): Texture =
  result = Texture()
  glGenTextures(1, result.id.addr)
  result.setMinifyFilter(MinifyFilter.Nearest)
  result.setMagnifyFilter(MagnifyFilter.Nearest)
  result.setWrapS(WrapMode.Repeat)
  result.setWrapT(WrapMode.Repeat)