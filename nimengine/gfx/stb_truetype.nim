import std/strutils

{.compile: "stb_truetype.c".}

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

const stbttHeader = currentSourceDir() & "/stb_truetype.h"

type
  stbtt_fontinfo* {.importc, header: stbttHeader.} = object

  stbtt_bakedchar* {.importc, header: stbttHeader.} = object
    x0*, y0*, x1*, y1*: cushort # coordinates of bbox in bitmap
    xoff*, yoff*, xadvance*: cfloat

proc stbtt_InitFont*(info: ptr stbtt_fontinfo, data: cstring, offset: cint): cint {.importc, header: stbttHeader.}
proc stbtt_GetFontBoundingBox*(info: ptr stbtt_fontinfo, x0, y0, x1, y1: ptr cint) {.importc, header: stbttHeader.}
proc stbtt_ScaleForPixelHeight*(info: ptr stbtt_fontinfo, pixels: cfloat): cfloat {.importc, header: stbttHeader.}
proc stbtt_BakeFontBitmap*(data: cstring, offset: cint, pixel_height: cfloat, pixels: ptr uint8, pw, ph, first_char, num_chars: cint, chardata: ptr stbtt_bakedchar): cint {.importc, header: stbttHeader.}