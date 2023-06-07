import vectorgraphics
import ../math

func drawFrameShadow*(gfx: VectorGraphics,
                      position, size: Vec2,
                      cornerRadius: float) =
  const feather = 10.0
  const feather2 = feather * 2.0
  gfx.beginPath()
  gfx.rect(-vec2(feather), size + feather2)
  gfx.roundedRect(position, size, cornerRadius)
  gfx.pathWinding = Hole
  gfx.fillPaint = gfx.boxGradient(
    vec2(position.x, position.y + 2),
    size,
    cornerRadius * 2.0,
    feather,
    rgba(0, 0, 0, 128), rgba(0, 0, 0, 0),
  )
  gfx.fill()

func drawFrame*(gfx: VectorGraphics,
                position, size: Vec2,
                borderThickness: float,
                cornerRadius: float,
                bodyColor, borderColor: Color) =
  let borderThickness = borderThickness.max(1.0)
  let borderThicknessHalf = borderThickness * 0.5

  gfx.saveState()

  # Body fill:
  gfx.beginPath()
  gfx.roundedRect(position, size, cornerRadius)
  gfx.fillColor = bodyColor
  gfx.fill()

  # Body border:
  gfx.beginPath()
  gfx.roundedRect(
    position + borderThicknessHalf,
    size - borderThickness,
    cornerRadius - borderThicknessHalf,
  )
  gfx.strokeWidth = borderThickness
  gfx.strokeColor = borderColor
  gfx.stroke()

  gfx.restoreState()

func drawFrameWithHeader*(gfx: VectorGraphics,
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

  gfx.saveState()

  # Header fill:
  gfx.beginPath()
  gfx.roundedRect(
    vec2(x, y),
    vec2(width, headerHeight),
    cornerRadius, cornerRadius,
    0, 0,
  )
  gfx.fillColor = headerColor
  gfx.fill()

  # Body fill:
  gfx.beginPath()
  gfx.roundedRect(
    vec2(x, y + headerHeight),
    vec2(width, height - headerHeight),
    0, 0,
    cornerRadius, cornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Body border:
  gfx.beginPath()
  gfx.moveTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  gfx.lineTo(vec2(x + width - borderThicknessHalf, y + height - cornerRadius))
  gfx.arcTo(
    vec2(x + width - borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + width - cornerRadius, y + height - borderThicknessHalf),
    borderCornerRadius,
  )
  gfx.lineTo(vec2(x + cornerRadius, y + height - borderThicknessHalf))
  gfx.arcTo(
    vec2(x + borderThicknessHalf, y + height - borderThicknessHalf),
    vec2(x + borderThicknessHalf, y + height - cornerRadius),
    borderCornerRadius,
  )
  gfx.lineTo(vec2(x + borderThicknessHalf, y + headerHeight))
  gfx.strokeWidth = borderThickness
  gfx.strokeColor = bodyBorderColor
  gfx.stroke()

  # Header border:
  gfx.beginPath()
  gfx.moveTo(vec2(x + borderThicknessHalf, y + headerHeight))
  gfx.lineTo(vec2(x + borderThicknessHalf, y + cornerRadius))
  gfx.arcTo(
    vec2(x + borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + cornerRadius, y + borderThicknessHalf),
    borderCornerRadius,
  )
  gfx.lineTo(vec2(x + width - cornerRadius, y + borderThicknessHalf))
  gfx.arcTo(
    vec2(x + width - borderThicknessHalf, y + borderThicknessHalf),
    vec2(x + width - borderThicknessHalf, y + cornerRadius),
    borderCornerRadius,
  )
  gfx.lineTo(vec2(x + width - borderThicknessHalf, y + headerHeight))
  gfx.strokeWidth = borderThickness
  gfx.strokeColor = headerBorderColor
  gfx.stroke()

  gfx.restoreState()