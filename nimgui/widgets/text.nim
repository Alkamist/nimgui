import ../gui

type
  GuiGlyph* = object
    index*: int
    position*: Vec2
    size*: Vec2

  GuiText* = ref object of GuiControl
    data*: string
    glyphs*: seq[GuiGlyph]
    lines*: seq[tuple[start, finish: int]]

proc update*(gui: Gui, text: GuiText) =
  text.glyphs.setLen(0)
  text.lines.setLen(0)

  let textPosition = text.position
  let lineHeight = gui.lineHeight

  var firstTime = true
  var newLine = false
  var lastMeasurement: GuiTextMeasurement
  var lineStart = 0

  var position = vec2(0, 0)

  for measurement in gui.measureText(text.data):
    if firstTime:
      lastMeasurement = measurement
      firstTime = false

    if newLine:
      text.lines.add((lineStart, lastMeasurement.index - 1))
      lineStart = measurement.index
      position.x = 0.0
      position.y += lineHeight
      lastMeasurement = measurement
      newLine = false

    if text.data[measurement.index] == '\n':
      newLine = true
    else:
      position.x += measurement.x - lastMeasurement.x
      text.glyphs.add(GuiGlyph(
        index: measurement.index,
        position: textPosition + position,
        size: vec2(measurement.width, lineHeight),
      ))

    lastMeasurement = measurement

  text.lines.add((lineStart, text.data.len - 1))

# proc update*(gui: Gui, text: GuiText) =
#   text.glyphs.setLen(0)
#   text.lines.setLen(0)

#   let textPosition = text.position
#   let lineHeight = gui.lineHeight

#   var firstTime = true
#   var lastMeasurement: GuiTextMeasurement
#   var lineStart = 0

#   for measurement in gui.measureText(text.data):
#     if firstTime:
#       lastMeasurement = measurement
#       firstTime = false

#     if text.data[measurement.index] == '\n':
#       text.lines.add((lineStart, lastMeasurement.index))
#       lineStart = measurement.index + 1
#     else:
#       text.glyphs.add(GuiGlyph(
#         index: measurement.index,
#         position: textPosition + vec2(measurement.x, 0),
#         size: vec2(measurement.width, lineHeight),
#       ))

#     lastMeasurement = measurement

# proc update*(gui: Gui, text: GuiText) =
#   text.glyphs.setLen(0)

#   # let clip = gui.clipStack[^1]

#   let textPosition = text.position
#   let lineHeight = gui.lineHeight

#   var position = vec2(0, 0)
#   var lastX = 0.0
#   var newLine = true

#   for measurement in gui.measureText(text.data):
#     if newLine:
#       lastX = measurement.x
#       newLine = false

#     if text.data[measurement.index] == '\n':
#       position.x = 0
#       position.y += lineHeight
#       newLine = true
#     else:
#       position.x += measurement.x - lastX
#       text.glyphs.add(GuiGlyph(
#         index: measurement.index,
#         position: textPosition + position,
#         size: vec2(measurement.width, lineHeight),
#       ))
#       lastX = measurement.x

proc draw*(gui: Gui, text: GuiText) =
  # gui.drawText(text.position, text.data)

  let lineHeight = gui.lineHeight
  var position = text.position
  for line in text.lines:
    gui.drawText(position, text.data[line.start..line.finish])
    position.y += lineHeight