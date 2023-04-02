import ../gfxmod; export gfxmod

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