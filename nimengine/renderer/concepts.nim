type
  SomeColorUInt8* = concept self
    self.r is uint8
    self.g is uint8
    self.b is uint8
    self.a is uint8

  SomeImage*[T: openArray[SomeColorUInt8]] = concept self
    self.width is int
    self.height is int
    self.data is T

  SomeVec2* = concept self
    self.x is SomeFloat
    self.y is SomeFloat

  SomeRect2* = concept self
    self.x is SomeFloat
    self.y is SomeFloat
    self.width is SomeFloat
    self.height is SomeFloat

  SomeColor* = concept self
    self.r is SomeFloat
    self.g is SomeFloat
    self.b is SomeFloat
    self.a is SomeFloat

  SomeUniform3fv* = concept self
    self[0] is float32
    self[1] is float32
    self[2] is float32

  SomeUniformMatrix4fv* = concept self
    self[0][0] is float32
    self[0][1] is float32
    self[0][2] is float32
    self[0][3] is float32
    self[1][0] is float32
    self[1][1] is float32
    self[1][2] is float32
    self[1][3] is float32
    self[2][0] is float32
    self[2][1] is float32
    self[2][2] is float32
    self[2][3] is float32
    self[3][0] is float32
    self[3][1] is float32
    self[3][2] is float32
    self[3][3] is float32