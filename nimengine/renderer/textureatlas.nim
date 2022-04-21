import std/tables
import std/options
import ./concepts
import ./texture

type
  TextureSlice* = tuple
    width, height: float32
    uv: tuple[left, right, bottom, top: float32]

  TextureAtlas* = object
    texture*: Texture
    idToSliceTable: Table[int, TextureSlice]

proc initTextureAtlas*(texture = initTexture()): TextureAtlas =
  TextureAtlas(texture: texture)

template width*(self: TextureAtlas): int = self.texture.width
template height*(self: TextureAtlas): int = self.texture.height
template upload*(self: var TextureAtlas, image: SomeImage) = self.texture.upload(image)

func getSlice*(self: TextureAtlas, id: int): Option[TextureSlice] =
  if self.idToSliceTable.contains(id):
    return some self.idToSliceTable[id]

func setSlice*(self: var TextureAtlas, id: int, rect: SomeRect) =
  let rectW = rect.width.float32
  let rectH = rect.height.float32
  let uScale = rectW / self.width.float32
  let vScale = rectH / self.height.float32
  let left = rect.x.float32 * uScale
  let right = left + rectW * uScale
  let bottom = rect.y.float32 * vScale
  let top = bottom + rectH * vScale
  self.idToSliceTable[id] = (
    width: rectW,
    height: rectH,
    uv: (
      left: left,
      right: right,
      bottom: bottom,
      top: top,
    ),
  )