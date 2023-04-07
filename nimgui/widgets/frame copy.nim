import ../gfxmod; export gfxmod

const sin45 = sin(45.0.degToRad)

func drawFrameShadow*(gfx: Gfx,
                      position, size: Vec2,
                      cornerRadius: float,
                      feather: float,
                      intensity: float) =
  let featherOffset = vec2(feather, feather)
  let featherOffsetHalf = featherOffset * 0.5
  let featherOffset2 = featherOffset * 2.0

  let shadowOffset = vec2(0, 0)
  let shadowPosition = shadowOffset - featherOffset
  let shadowSize = size + featherOffset2

  let shadowPaint = gfx.boxGradient(
    shadowOffset - featherOffsetHalf,
    size + featherOffset,
    cornerRadius + sin45 * feather,
    feather,
    rgba(0, 0, 0, (255.0 * intensity).uint8),
    rgba(0, 0, 0, 0),
  )
  gfx.beginPath()
  gfx.rect(shadowPosition, shadowSize)
  gfx.roundedRect(position, size, cornerRadius)
  gfx.pathWinding = Hole
  gfx.fillPaint = shadowPaint
  gfx.fill()

func drawFrame*(gfx: Gfx,
                position, size: Vec2,
                borderThickness: float,
                cornerRadius: float,
                bodyColor, borderColor: Color) =
  let halfBorderThickness = borderThickness * 0.5

  let leftOuter = position.x
  let leftMiddle = leftOuter + halfBorderThickness
  let leftInner = leftMiddle + halfBorderThickness
  let rightOuter = position.x + size.x
  let rightMiddle = rightOuter - halfBorderThickness
  let rightInner = rightMiddle - halfBorderThickness
  let topOuter = position.y
  let topMiddle = topOuter + halfBorderThickness
  let topInner = topMiddle + halfBorderThickness
  let bottomOuter = position.y + size.y
  let bottomMiddle = bottomOuter - halfBorderThickness
  let bottomInner = bottomMiddle - halfBorderThickness

  let outerCornerRadius = cornerRadius
  let middleCornerRadius = outerCornerRadius - halfBorderThickness
  let innerCornerRadius = middleCornerRadius - halfBorderThickness

  # Body fill.
  gfx.beginPath()
  gfx.roundedRect(
    vec2(leftMiddle, topMiddle),
    vec2(rightMiddle - leftMiddle, bottomMiddle - topMiddle),
    middleCornerRadius,
    middleCornerRadius,
    middleCornerRadius,
    middleCornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Border outer.
  gfx.beginPath()
  gfx.roundedRect(position, size, cornerRadius)

  # Body inner hole.
  gfx.roundedRect(
    vec2(leftInner, topInner),
    vec2(rightInner - leftInner, bottomInner - topInner),
    innerCornerRadius,
    innerCornerRadius,
    innerCornerRadius,
    innerCornerRadius,
  )
  gfx.pathWinding = Hole

  gfx.fillColor = borderColor
  gfx.fill()

func drawFrameWithHeader*(gfx: Gfx,
                          position, size: Vec2,
                          borderThickness, headerHeight: float,
                          cornerRadius: float,
                          bodyColor, headerColor, borderColor: Color) =
  let borderThickness = borderThickness.clamp(1.0, 0.5 * headerHeight)
  let halfBorderThickness = borderThickness * 0.5

  let leftOuter = position.x
  let leftMiddle = leftOuter + halfBorderThickness
  let leftInner = leftMiddle + halfBorderThickness
  let rightOuter = position.x + size.x
  let rightMiddle = rightOuter - halfBorderThickness
  let rightInner = rightMiddle - halfBorderThickness
  let topOuter = position.y
  let topMiddle = topOuter + halfBorderThickness
  let topInner = topMiddle + halfBorderThickness
  let headerOuter = position.y + headerHeight
  let headerMiddle = headerOuter - halfBorderThickness
  let headerInner = headerMiddle - halfBorderThickness
  let bottomOuter = position.y + size.y
  let bottomMiddle = bottomOuter - halfBorderThickness
  let bottomInner = bottomMiddle - halfBorderThickness

  let innerWidth = rightInner - leftInner
  let middleWidth = rightMiddle - leftMiddle

  let outerCornerRadius = cornerRadius
  let middleCornerRadius = outerCornerRadius - halfBorderThickness
  let innerCornerRadius = middleCornerRadius - halfBorderThickness

  # Header fill.
  gfx.beginPath()
  gfx.roundedRect(
    vec2(leftMiddle, topMiddle),
    vec2(middleWidth, headerMiddle - topMiddle),
    middleCornerRadius,
    middleCornerRadius,
    0, 0,
  )
  gfx.fillColor = headerColor
  gfx.fill()

  # Body fill.
  gfx.beginPath()
  gfx.roundedRect(
    vec2(leftMiddle, headerMiddle),
    vec2(middleWidth, bottomMiddle - headerMiddle),
    0, 0,
    middleCornerRadius,
    middleCornerRadius,
  )
  gfx.fillColor = bodyColor
  gfx.fill()

  # Border outer.
  gfx.beginPath()
  gfx.roundedRect(position, size, cornerRadius)

  # Header inner hole.
  gfx.roundedRect(
    vec2(leftInner, topInner),
    vec2(innerWidth, headerInner - topInner),
    innerCornerRadius,
    innerCornerRadius,
    0, 0,
  )
  gfx.pathWinding = Hole

  # Body inner hole.
  gfx.roundedRect(
    vec2(leftInner, headerOuter),
    vec2(innerWidth, bottomInner - headerOuter),
    0, 0,
    innerCornerRadius,
    innerCornerRadius,
  )
  gfx.pathWinding = Hole

  gfx.fillColor = borderColor
  gfx.fill()