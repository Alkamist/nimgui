type
  ColorRgbxConcept* = concept c
    c.r is uint8
    c.g is uint8
    c.b is uint8
    c.a is uint8

  ColorRgbaConcept* = concept c
    c.r is float32
    c.g is float32
    c.b is float32
    c.a is float32

  FVec3Concept* = concept v
    v.x is float32
    v.y is float32
    v.z is float32

  FMat4Concept* = concept m
    m[0][0] is float32
    m[0][1] is float32
    m[0][2] is float32
    m[0][3] is float32
    m[1][0] is float32
    m[1][1] is float32
    m[1][2] is float32
    m[1][3] is float32
    m[2][0] is float32
    m[2][1] is float32
    m[2][2] is float32
    m[2][3] is float32
    m[3][0] is float32
    m[3][1] is float32
    m[3][2] is float32
    m[3][3] is float32