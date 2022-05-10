{.experimental: "overloadableEnums".}

import pkg/opengl
export opengl

type
  # TextureFormat* = enum
  #   Red = GL_RED
  #   Rg = GL_RG
  #   Rgb = GL_RGB
  #   Bgr = GL_BGR
  #   Rgba = GL_RGBA
  #   Bgra = GL_BGRA
  #   RedInteger = GL_RED_INTEGER
  #   RgInteger = GL_RG_INTEGER
  #   RgbInteger = GL_RGB_INTEGER
  #   BgrInteger = GL_BGR_INTEGER
  #   RgbaInteger = GL_RGBA_INTEGER
  #   BgraInteger = GL_BGRA_INTEGER
  #   StencilIndex = GL_STENCIL_INDEX
  #   DepthComponent = GL_DEPTH_COMPONENT
  #   DepthStencil = GL_DEPTH_STENCIL

  MinifyFilter* = enum
    Nearest = GL_NEAREST
    Linear = GL_LINEAR
    NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST
    LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST
    NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR
    LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR

  MagnifyFilter* = enum
    Nearest = GL_NEAREST
    Linear = GL_LINEAR

  WrapMode* = enum
    Repeat = GL_REPEAT
    ClampToBorder = GL_CLAMP_TO_BORDER
    ClampToEdge = GL_CLAMP_TO_EDGE
    MirroredRepeat = GL_MIRRORED_REPEAT
    MirrorClampToEdge = GL_MIRROR_CLAMP_TO_EDGE

  Texture* = ref object
    id*: GLuint
    width*, height*: int

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

proc upload*(texture: Texture, width, height: int, data: openArray[uint8]) =
  texture.width = width
  texture.height = height
  texture.select()
  glTexImage2D(
    target = GL_TEXTURE_2D,
    level = 0,
    internalformat = GL_RGBA.GLint,
    width = width.GLsizei,
    height = height.GLsizei,
    border = 0,
    format = GL_RGBA,
    `type` = GL_UNSIGNED_BYTE,
    pixels = data[0].unsafeAddr,
  )

proc generateMipmap*(texture: Texture) =
  texture.select()
  glGenerateMipmap(GL_TEXTURE_2D)

proc `=destroy`*(texture: var type Texture()[]) =
  glDeleteTextures(1, texture.id.addr)

proc newTexture*(): Texture =
  result = Texture()
  glGenTextures(1, result.id.addr)
  result.setMinifyFilter(Nearest)
  result.setMagnifyFilter(Nearest)
  result.setWrapS(Repeat)
  result.setWrapT(Repeat)