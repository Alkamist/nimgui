import vectorgraphics
import ../math

func drawFrameShadow*(vg: VectorGraphics,
                      position, size: Vec2,
                      cornerRadius: float) =
  const feather = 10.0
  const feather2 = feather * 2.0
  vg.beginPath()
  vg.rect(-vec2(feather), size + feather2)
  vg.roundedRect(position, size, cornerRadius)
  vg.pathWinding = Hole
  vg.fillPaint = vg.boxGradient(
    vec2(position.x, position.y + 2),
    size,
    cornerRadius * 2.0,
    feather,
    rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
  )
  vg.fill()

func drawFrame*(vg: VectorGraphics,
                position, size: Vec2,
                borderThickness: float,
                cornerRadius: float,
                bodyColor, borderColor: Color) =
  let borderThickness = borderThickness.max(1.0)
  let borderThicknessHalf = borderThickness * 0.5

  vg.saveState()

  # Body fill:
  vg.beginPath()
  vg.roundedRect(position, size, cornerRadius)
  vg.fillColor = bodyColor
  vg.fill()

  # Body border:
  vg.beginPath()
  vg.roundedRect(
    position + borderThicknessHalf,
    size - borderThickness,
    cornerRadius - borderThicknessHalf,
  )
  vg.strokeWidth = borderThickness
  vg.strokeColor = borderColor
  vg.stroke()

  vg.restoreState()

func drawFrameWithHeader*(vg: VectorGraphics,
                          position, size: Vec2,
                          borderThickness, headerHeight: float,
                          cornerRadius: float,
                          bodyColor, bodyBorderColor: Color,
                          headerColor, headerBorderColor: Color) =
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let borderThicknessHalf = borderThickness * 0.5

  let borderCornerRadius = cornerRadius - borderThicknessHalf

  let x = position.x
  let y = position.y
  let width = size.x
  let height = size.y

  vg.saveState()

  # Header fill:
  vg.beginPath()
  vg.roundedRect(
    vec2(x, y),
    vec2(width, headerHeight),
    cornerRadius, cornerRadius,
    0, 0,
  )
  vg.fillColor = headerColor
  vg.fill()

  # Body fill:
  vg.beginPath()
  vg.roundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  vg.fillColor = bodyColor
  vg.fill()

  # Body border:
  vg.beginPath()
  vg.moveTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  vg.lineTo(vec2(x + width - borderThicknessHalf, y + height - cornerRadius))
  vg.arcTo(
    vec2(x + width - borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + width - cornerRadius, y + height - borderThicknessHalf),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + cornerRadius, y + height - borderThicknessHalf))
  vg.arcTo(
    vec2(x + borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + borderThicknessHalf, y + height - cornerRadius),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + borderThicknessHalf, y + headerHeight))
  vg.strokeWidth = borderThickness
  vg.strokeColor = bodyBorderColor
  vg.stroke()

  # Header border:
  vg.beginPath()
  vg.moveTo(vec2(x + borderThicknessHalf, y + headerHeight))
  vg.lineTo(vec2(x + borderThicknessHalf, y + cornerRadius))
  vg.arcTo(
    vec2(x + borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + cornerRadius, y + borderThicknessHalf),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + width - cornerRadius, y + borderThicknessHalf))
  vg.arcTo(
    vec2(x + width - borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + width - borderThicknessHalf, y + cornerRadius),
    borderCornerRadius,
  )
  vg.lineTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  vg.strokeWidth = borderThickness
  vg.strokeColor = headerBorderColor
  vg.stroke()

  vg.restoreState()