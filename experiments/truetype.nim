import std/strutils

{.compile: "stb_truetype.c".}

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

const stbttHeader = currentSourceDir() & "/stb_truetype.h"

type
  stbtt_fontinfo* {.importc, header: stbttHeader.} = object

proc stbtt_InitFont*(info: ptr stbtt_fontinfo, data: cstring, offset: cint): cint {.importc, header: stbttHeader.}
proc stbtt_ScaleForPixelHeight*(info: ptr stbtt_fontinfo, pixels: cfloat): cfloat {.importc, header: stbttHeader.}
proc stbtt_GetFontVMetrics*(info: ptr stbtt_fontinfo, ascent, descent, lineGap: ptr cint) {.importc, header: stbttHeader.}
proc stbtt_GetCodepointHMetrics*(info: ptr stbtt_fontinfo, codepoint: cint, advanceWidth, leftSideBearing: ptr cint) {.importc, header: stbttHeader.}
proc stbtt_GetCodepointBitmapBox*(info: ptr stbtt_fontinfo, codepoint: cint, scale_x, scale_y: cfloat, ix0, iy0, ix1, iy1: ptr cint) {.importc, header: stbttHeader.}
proc stbtt_MakeCodepointBitmap*(info: ptr stbtt_fontinfo, output: ptr uint8, out_w, out_h, out_stride: cint, scale_x, scale_y: cfloat, codepoint: cint) {.importc, header: stbttHeader.}
proc stbtt_GetCodepointKernAdvance*(info: ptr stbtt_fontinfo, ch1, ch2: cint): cint {.importc, header: stbttHeader.}