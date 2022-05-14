import std/unicode
import std/tables
import std/math
import ./stb_truetype

export tables

type
  GlyphInfo = tuple
    x, y: int
    width, height: int
    xOffset, yOffset: float
    xAdvance: float
    uv: tuple[x, y, width, height: float]

  CanvasAtlas* = ref object
    width*, height*: int
    data*: seq[uint8]
    whitePixel*: tuple[x, y: int]
    whitePixelUv*: tuple[x, y, width, height: float]
    glyphInfoTable*: Table[Rune, GlyphInfo]
    glyphBoundingBox*: (tuple[x, y: float], tuple[x, y: float])
    stbFontInfo: stbtt_fontinfo

func addWhitePixels(atlas: CanvasAtlas) =
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
  atlas.whitePixel.x = 1
  atlas.whitePixel.y = (atlas.height - 1)

proc loadFont(atlas: CanvasAtlas, fontData: string, fontSize: float, firstChar, numChars: int) =
  if stbtt_InitFont(atlas.stbFontInfo.addr, fontData.cstring, 0) == 0:
    echo "Failed to load font."

  var x0, y0, x1, y1: cint
  stbtt_GetFontBoundingBox(atlas.stbFontInfo.addr, x0.addr, y0.addr, x1.addr, y1.addr)

  let fontScale = stbtt_ScaleForPixelHeight(atlas.stbFontInfo.addr, fontSize)

  atlas.glyphBoundingBox = (
    (fontScale * x0.float, fontScale * y0.float),
    (fontScale * x1.float, fontScale * y1.float),
  )

  let charsPerRowGuess = numChars.float.sqrt.ceil
  let widthHeightGuess = (charsPerRowGuess * fontSize).ceil.int

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
      pixel_height = fontSize,
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
      atlas.height += (rowsMissingGuess * fontSize).ceil.int

  # Convert the raw alphas to white pixels.
  for i, alpha in rawAlphas:
    let i4 = i * 4
    atlas.data[i4] = 255
    atlas.data[i4 + 1] = 255
    atlas.data[i4 + 2] = 255
    atlas.data[i4 + 3] = alpha

  for i, data in chardata:
    let rune = (firstChar + i).Rune

    let width = data.x1.float - data.x0.float
    let height = data.y1.float - data.y0.float

    atlas.glyphInfoTable[rune] = (
      x: data.x0.int,
      y: data.y0.int,
      width: width.int,
      height: height.int,
      xOffset: data.xoff.float,
      yOffset: data.yoff.float,
      xAdvance: data.xadvance.float,
      uv: (x: 0.0, y: 0.0, width: 0.0, height: 0.0),
    )

proc calculateUvs(atlas: CanvasAtlas) =
  atlas.whitePixelUv.x = atlas.whitePixel.x / atlas.width
  atlas.whitePixelUv.y = atlas.whitePixel.y / atlas.height

  for rune in atlas.glyphInfoTable.keys:
    atlas.glyphInfoTable[rune].uv.x = atlas.glyphInfoTable[rune].x / atlas.width
    atlas.glyphInfoTable[rune].uv.y = atlas.glyphInfoTable[rune].y / atlas.height
    atlas.glyphInfoTable[rune].uv.width = atlas.glyphInfoTable[rune].width / atlas.width
    atlas.glyphInfoTable[rune].uv.height = atlas.glyphInfoTable[rune].height / atlas.height

proc newCanvasAtlas*(fontData: string, fontSize: float, firstChar = 0, numChars = 128): CanvasAtlas =
  result = CanvasAtlas()
  result.loadFont(fontData, fontSize, firstChar, numChars)
  result.addWhitePixels()
  result.calculateUvs()