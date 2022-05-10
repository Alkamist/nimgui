import std/unicode
import std/tables
import std/math
import ./stb_truetype
import ../gmath
import ../gmath/types

type
  CanvasAtlas* = ref object
    width*, height*: int
    data*: seq[uint8]
    whitePixelUv*: Vec2
    characterRects*: Table[Rune, Rect2]
    characterUvs*: Table[Rune, Rect2]

proc addWhitePixels(atlas: CanvasAtlas) =
  let extraPixelRows = 6
  let endOfFont = atlas.data.len
  atlas.data.setLen(endOfFont + atlas.width * extraPixelRows * 4)

  for extraRow in 3 ..< extraPixelRows:
    let y = atlas.height + extraRow
    for x in 0 ..< 3:
      let i4 = (y * atlas.width + x) * 4
      atlas.data[i4] = 255
      atlas.data[i4 + 1] = 255
      atlas.data[i4 + 2] = 255
      atlas.data[i4 + 3] = 255

  atlas.height += extraPixelRows
  atlas.whitePixelUv.x = 1 / atlas.width
  atlas.whitePixelUv.y = (atlas.height - 1) / atlas.height

proc loadFont(atlas: CanvasAtlas, fontData: string, pixelHeight: float, firstChar = 0, numChars = 96) =
  let charsPerRowGuess = numChars.float.sqrt.ceil
  let widthHeightGuess = (charsPerRowGuess * pixelHeight).ceil.int

  atlas.width = widthHeightGuess
  atlas.height = widthHeightGuess

  var rawAlphas: seq[uint8]
  var chardata = newSeq[stbtt_bakedchar](numChars)

  const maxLoops = 8
  for _ in 0 ..< maxLoops:
    rawAlphas.setLen(atlas.width * atlas.height)
    atlas.data = newSeq[uint8](atlas.width * atlas.height * 4)

    let retVal = stbtt_BakeFontBitmap(
      data = fontData.cstring,
      offset = 0,
      pixel_height = pixelHeight,
      pixels = rawAlphas[0].addr,
      pw = atlas.width.cint,
      ph = atlas.height.cint,
      first_char = firstChar.cint,
      num_chars = numChars.cint,
      chardata = chardata[0].addr,
    )

    # All characters fit, so trim the excess.
    if retVal > 0:
      atlas.height = retVal
      rawAlphas.setLen(atlas.width * atlas.height)
      break

    # Characters are missing so try again with a taller image.
    else:
      let charactersMissing = numChars + retVal
      let rowsMissingGuess = (charactersMissing.float / charsPerRowGuess).ceil
      atlas.height += (rowsMissingGuess * pixelHeight).ceil.int

  # Convert the raw alphas to white pixels.
  for i, alpha in rawAlphas:
    let i4 = i * 4
    atlas.data[i4] = 255
    atlas.data[i4 + 1] = 255
    atlas.data[i4 + 2] = 255
    atlas.data[i4 + 3] = alpha

proc newCanvasAtlas*(fontData: string, pixelHeight: float): CanvasAtlas =
  result = CanvasAtlas()
  result.loadFont(fontData, pixelHeight)
  result.addWhitePixels()