import std/math
import ./truetype

let fontData = readFile("experiments/Roboto-Regular_1.ttf").cstring

var info: stbtt_fontinfo
if stbtt_InitFont(info.addr, fontData, 0) == 0:
  echo "stbtt_InitFont failed."

const imageWidth* = 300
const imageHeight* = 30
var rawImage = newSeq[uint8](imageWidth * imageHeight)

let scale = stbtt_ScaleForPixelHeight(info.addr, 24)

let text = "abcdefghijklmnopqrstuvwxyz".cstring

var x: cint
var ascent, descent, lineGap: cint
stbtt_GetFontVMetrics(info.addr, ascent.addr, descent.addr, lineGap.addr)

ascent = (ascent.float * scale).round.cint
descent = (descent.float * scale).round.cint

for i in 0 ..< text.len:
  var ax: cint
  var lsb: cint
  stbtt_GetCodepointHMetrics(info.addr, text[i].cint, ax.addr, lsb.addr)

  var c_x1: cint
  var c_y1: cint
  var c_x2: cint
  var c_y2: cint
  stbtt_GetCodepointBitmapBox(info.addr, text[i].cint, scale, scale, c_x1.addr, c_y1.addr, c_x2.addr, c_y2.addr)

  var y = ascent + c_y1

  var byteOffset = (x + (lsb.float * scale).round.cint + (y * imageWidth)).cint
  stbtt_MakeCodepointBitmap(info.addr, rawImage[byteOffset].addr, c_x2 - c_x1, c_y2 - c_y1, imageWidth, scale, scale, text[i].cint)

  x += (ax.float * scale).round.cint

  var kern: cint
  kern = stbtt_GetCodepointKernAdvance(info.addr, text[i].cint, text[i + 1].cint)
  x += (kern.float * scale).round.cint

var testImage* = newSeq[uint8](imageWidth * imageHeight * 4)
for i, raw in rawImage:
  let i4 = i * 4
  testImage[i4] = 255
  testImage[i4 + 1] = 255
  testImage[i4 + 2] = 255
  testImage[i4 + 3] = raw