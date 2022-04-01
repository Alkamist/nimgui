import pkg/opengl
import pkg/pixie

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
    backgroundColor*: Color
    image*: Image

proc clear*(texture: Texture) =
  texture.image.fill(texture.backgroundColor)

proc resize*(texture: Texture, width, height: int) =
  texture.image.width = width
  texture.image.height = height
  texture.image.data.setLen(width * height)

proc loadFile*(texture: var Texture, file: string) =
  texture.image = pixie.readImage(file)

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

proc uploadData*(texture: Texture) =
  texture.select()
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA.GLint,
    texture.image.width.GLsizei,
    texture.image.height.GLsizei,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    texture.image.data[0].addr,
  )

proc generateMipmap*(texture: Texture) =
  texture.select()
  glGenerateMipmap(GL_TEXTURE_2D)

proc init*(_: type Texture, width, height: int): Texture =
  glGenTextures(1, result.id.addr)
  result.backgroundColor = color(0.0, 0.0, 0.0, 0.0)
  result.image = newImage(width, height)
  result.setMinifyFilter MinifyFilter.Nearest
  result.setMagnifyFilter MagnifyFilter.Nearest
  result.setWrapS WrapMode.Repeat
  result.setWrapT WrapMode.Repeat