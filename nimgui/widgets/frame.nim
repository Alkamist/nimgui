# import vectorgraphics
# import ../math

# func drawFrameShadow*(vg: VectorGraphics,
#                       x, y, width, height: float,
#                       cornerRadius: float) =
#   const feather = 10.0
#   const feather2 = feather * 2.0
#   let shadowPaint = vg.boxGradient(
#     x, y + 2,
#     width, height,
#     cornerRadius * 2.0,
#     feather,
#     rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
#   )
#   vg.beginPath()
#   vg.rect(-feather, -feather, width + feather2, height + feather2)
#   vg.roundedRect(x, y, width, height, cornerRadius)
#   vg.pathWinding = Hole
#   vg.fillPaint = shadowPaint
#   vg.fill()

# func drawFrame*(vg: VectorGraphics,
#                 x, y, width, height: float,
#                 borderThickness: float,
#                 cornerRadius: float,
#                 bodyColor, borderColor: Color) =
#   let borderThickness = borderThickness.max(1.0)
#   let borderThicknessHalf = borderThickness * 0.5

#   vg.saveState()

#   # Body fill:
#   vg.beginPath()
#   vg.roundedRect(
#     x, y,
#     width, height,
#     cornerRadius, cornerRadius,
#     cornerRadius, cornerRadius,
#   )
#   vg.fillColor = bodyColor
#   vg.fill()

#   # Body border:
#   vg.beginPath()
#   vg.roundedRect(
#     x + borderThicknessHalf, y + borderThicknessHalf,
#     width - borderThickness, height - borderThickness,
#     cornerRadius - borderThicknessHalf,
#   )
#   vg.strokeWidth = borderThickness
#   vg.strokeColor = borderColor
#   vg.stroke()

#   vg.restoreState()

# func drawFrameWithHeader*(vg: VectorGraphics,
#                           x, y, width, height: float,
#                           borderThickness, headerHeight: float,
#                           cornerRadius: float,
#                           bodyColor, bodyBorderColor: Color,
#                           headerColor, headerBorderColor: Color) =
#   let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
#   let borderThicknessHalf = borderThickness * 0.5

#   let borderCornerRadius = cornerRadius - borderThicknessHalf

#   vg.saveState()

#   # Header fill:
#   vg.beginPath()
#   vg.roundedRect(
#     x, y,
#     width, headerHeight,
#     cornerRadius, cornerRadius,
#     0, 0,
#   )
#   vg.fillColor = headerColor
#   vg.fill()

#   # Body fill:
#   vg.beginPath()
#   vg.roundedRect(
#     x, y + headerHeight,
#     width, height - headerHeight,
#     0, 0,
#     cornerRadius, cornerRadius,
#   )
#   vg.fillColor = bodyColor
#   vg.fill()

#   # Body border:
#   vg.beginPath()
#   vg.moveTo(x + width - borderThicknessHalf, y + headerHeight)
#   vg.lineTo(x + width - borderThicknessHalf, y + height - cornerRadius)
#   vg.arcTo(
#     x + width - borderThicknessHalf, y + height - borderThicknessHalf,
#     x + width - cornerRadius, y + height - borderThicknessHalf,
#     borderCornerRadius,
#   )
#   vg.lineTo(x + cornerRadius, y + height - borderThicknessHalf)
#   vg.arcTo(
#     x + borderThicknessHalf, y + height - borderThicknessHalf,
#     x + borderThicknessHalf, y + height - cornerRadius,
#     borderCornerRadius,
#   )
#   vg.lineTo(x + borderThicknessHalf, y + headerHeight)
#   vg.strokeWidth = borderThickness
#   vg.strokeColor = bodyBorderColor
#   vg.stroke()

#   # Header border:
#   vg.beginPath()
#   vg.moveTo(x + borderThicknessHalf, y + headerHeight)
#   vg.lineTo(x + borderThicknessHalf, y + cornerRadius)
#   vg.arcTo(
#     x + borderThicknessHalf, y + borderThicknessHalf,
#     x + cornerRadius, y + borderThicknessHalf,
#     borderCornerRadius,
#   )
#   vg.lineTo(x + width - cornerRadius, y + borderThicknessHalf)
#   vg.arcTo(
#     x + width - borderThicknessHalf, y + borderThicknessHalf,
#     x + width - borderThicknessHalf, y + cornerRadius,
#     borderCornerRadius,
#   )
#   vg.lineTo(x + width - borderThicknessHalf, y + headerHeight)
#   vg.strokeWidth = borderThickness
#   vg.strokeColor = headerBorderColor
#   vg.stroke()

#   vg.restoreState()