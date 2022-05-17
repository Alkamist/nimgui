import std/unicode
import std/tables
import std/math
import ./stb_truetype

export tables

type
  GlyphInfo = tuple
    position: tuple[x, y: int]
    size: tuple[x, y: int]
    offset: tuple[x, y: float]
    xAdvance: float
    uv: tuple[position, size: tuple[x, y: float]]

  CanvasAtlas* = ref object
    size*: tuple[x, y: int]
    data*: seq[uint8]
    whitePixelPosition*: tuple[x, y: int]
    whitePixelUv*: tuple[position, size: tuple[x, y: float]]
    glyphInfoTable*: Table[Rune, GlyphInfo]
    glyphBoundingBox*: tuple[position, size: tuple[x, y: float]]
    stbFontInfo: stbtt_fontinfo

func addWhitePixels(atlas: CanvasAtlas) =
  let extraPixelRows = 6
  let endOfFont = atlas.data.len
  atlas.data.setLen(endOfFont + atlas.size.x * extraPixelRows * 4)

  for extraRow in 3 ..< extraPixelRows:
    let y = atlas.size.y + extraRow
    for x in 0 ..< 3:
      let i4 = (y * atlas.size.x + x) * 4
      if i4 + 3 < atlas.data.len:
        atlas.data[i4] = 255
        atlas.data[i4 + 1] = 255
        atlas.data[i4 + 2] = 255
        atlas.data[i4 + 3] = 255

  atlas.size.y += extraPixelRows
  atlas.whitePixelPosition = (1, (atlas.size.y - 1))

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

  atlas.size.x = widthHeightGuess
  atlas.size.y = widthHeightGuess

  var rawAlphas: seq[uint8]
  var chardata = newSeq[stbtt_bakedchar](numChars)

  const maxLoops = 8
  for _ in 0 ..< maxLoops:
    rawAlphas.setLen(atlas.size.x * atlas.size.y)
    atlas.data = newSeq[uint8](atlas.size.x * atlas.size.y * 4)

    let retVal = stbtt_BakeFontBitmap(
      data = fontData.cstring,
      offset = 0,
      pixel_height = fontSize,
      pixels = rawAlphas[0].addr,
      pw = atlas.size.x.cint,
      ph = atlas.size.y.cint,
      first_char = firstChar.cint,
      num_chars = numChars.cint,
      chardata = chardata[0].addr,
    )

    # All characters fit, so trim the excess.
    if retVal > 0:
      atlas.size.y = retVal
      rawAlphas.setLen(atlas.size.x * atlas.size.y)
      break

    # Characters are missing so try again with a taller image.
    else:
      let charactersMissing = numChars + retVal
      let rowsMissingGuess = (charactersMissing.float / charsPerRowGuess).ceil
      atlas.size.y += (rowsMissingGuess * fontSize).ceil.int

  # Convert the raw alphas to white pixels.
  for i, alpha in rawAlphas:
    let i4 = i * 4
    atlas.data[i4] = 255
    atlas.data[i4 + 1] = 255
    atlas.data[i4 + 2] = 255
    atlas.data[i4 + 3] = alpha

  for i, data in chardata:
    let rune = (firstChar + i).Rune
    atlas.glyphInfoTable[rune] = (
      position: (data.x0.int, data.y0.int),
      size: ((data.x1.float - data.x0.float).int, (data.y1.float - data.y0.float).int),
      offset: (data.xoff.float, data.yoff.float),
      xAdvance: data.xadvance.float,
      uv: (position: (0.0, 0.0), size: (0.0, 0.0)),
    )

proc calculateUvs(atlas: CanvasAtlas) =
  atlas.whitePixelUv = (
    position: (atlas.whitePixelPosition.x / atlas.size.x,
               atlas.whitePixelPosition.y / atlas.size.y),
    size: (0.0, 0.0),
  )

  for rune in atlas.glyphInfoTable.keys:
    atlas.glyphInfoTable[rune].uv.position.x = atlas.glyphInfoTable[rune].position.x / atlas.size.x
    atlas.glyphInfoTable[rune].uv.position.y = atlas.glyphInfoTable[rune].position.y / atlas.size.y
    atlas.glyphInfoTable[rune].uv.size.x = atlas.glyphInfoTable[rune].size.x / atlas.size.x
    atlas.glyphInfoTable[rune].uv.size.y = atlas.glyphInfoTable[rune].size.y / atlas.size.y

proc newCanvasAtlas*(fontData: string, fontSize: float, firstChar = 0, numChars = 128): CanvasAtlas =
  result = CanvasAtlas()
  result.loadFont(fontData, fontSize, firstChar, numChars)
  result.addWhitePixels()
  result.calculateUvs()