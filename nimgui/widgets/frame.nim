import ../gfxmod; export gfxmod

func drawFrameShadow*(gfx: Gfx,
                      x, y, width, height: float,
                      cornerRadius: float) =
  const feather = 10.0
  const feather2 = feather * 2.0
  let shadowPaint = gfx.boxGradient(
    x, y + 2,
    width, height,
    cornerRadius * 2.0,
    feather,
    rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
  )
  gfx.beginPath()
  gfx.rect(-feather, -feather, width + feather2, height + feather2)
  gfx.roundedRect(x, y, width, height, cornerRadius)
  gfx.pathWinding = Hole
  gfx.fillPaint = shadowPaint
  gfx.fill()

func drawFrame*(gfx: Gfx,
                x, y, width, height: float,
                borderThickness: float,
                cornerRadius: float,
                bodyColor, borderColor: Color) =
  let borderThickness = borderThickness.max(1.0)
  let borderThicknessHalf = borderThickness * 0.5
  let borderThickness2 = borderThickness * 2.0

  let middleCornerRadius = cornerRadius - borderThicknessHalf
  let innerCornerRadius = middleCornerRadius - borderThicknessHalf

  gfx.saveState()

  # Body fill:
  gfx.beginPath()
  gfx.roundedRect(
    x + borderThickness, y + borderThickness,
    width - borderThickness2, height - borderThickness2,
    innerCornerRadius, innerCornerRadius,
    innerCornerRadius, innerCornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Body border:
  gfx.beginPath()
  gfx.roundedRect(
    x + borderThicknessHalf, y + borderThicknessHalf,
    width - borderThickness, height - borderThickness,
    middleCornerRadius, middleCornerRadius,
    middleCornerRadius, middleCornerRadius,
  )
  gfx.strokeWidth = borderThickness
  gfx.strokeColor = borderColor
  gfx.stroke()

  gfx.restoreState()

func drawFrameWithHeader*(gfx: Gfx,
                          x, y, width, height: float,
                          borderThickness, headerHeight: float,
                          cornerRadius: float,
                          bodyColor, bodyBorderColor: Color,
                          headerColor, headerBorderColor: Color) =
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let borderThicknessHalf = borderThickness * 0.5
  let borderThickness2 = borderThickness * 2.0

  let middleCornerRadius = cornerRadius - borderThicknessHalf
  let innerCornerRadius = middleCornerRadius - borderThicknessHalf

  gfx.saveState()

  # Header fill:
  gfx.beginPath()
  gfx.roundedRect(
    x + borderThickness, y + borderThickness,
    width - borderThickness2, headerHeight - borderThickness,
    innerCornerRadius, innerCornerRadius,
    0, 0,
  )
  gfx.fillColor = headerColor
  gfx.fill()

  # Body fill:
  gfx.beginPath()
  gfx.roundedRect(
    x + borderThickness, y + headerHeight,
    width - borderThickness2, height - headerHeight - borderThickness,
    0, 0,
    innerCornerRadius, innerCornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Body border:
  gfx.beginPath()
  gfx.moveTo(x + width - borderThicknessHalf, y + headerHeight)
  gfx.lineTo(x + width - borderThicknessHalf, y + height - cornerRadius)
  gfx.arcTo(
    x + width - borderThicknessHalf, y + height - borderThicknessHalf,
    x + width - cornerRadius, y + height - borderThicknessHalf,
    middleCornerRadius,
  )
  gfx.lineTo(x + cornerRadius, y + height - borderThicknessHalf)
  gfx.arcTo(
    x + borderThicknessHalf, y + height - borderThicknessHalf,
    x + borderThicknessHalf, y + height - cornerRadius,
    middleCornerRadius,
  )
  gfx.lineTo(x + borderThicknessHalf, y + headerHeight)
  gfx.strokeWidth = borderThickness
  gfx.strokeColor = bodyBorderColor
  gfx.stroke()

  # Header border:
  gfx.beginPath()
  gfx.moveTo(x + borderThicknessHalf, y + headerHeight)
  gfx.lineTo(x + borderThicknessHalf, y + cornerRadius)
  gfx.arcTo(
    x + borderThicknessHalf, y + borderThicknessHalf,
    x + cornerRadius, y + borderThicknessHalf,
    middleCornerRadius,
  )
  gfx.lineTo(x + width - cornerRadius, y + borderThicknessHalf)
  gfx.arcTo(
    x + width - borderThicknessHalf, y + borderThicknessHalf,
    x + width - borderThicknessHalf, y + cornerRadius,
    middleCornerRadius,
  )
  gfx.lineTo(x + width - borderThicknessHalf, y + headerHeight)
  gfx.strokeWidth = borderThickness
  gfx.strokeColor = headerBorderColor
  gfx.stroke()

  gfx.restoreState()