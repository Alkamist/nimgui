type
  SomeRect2* = concept s
    s.x
    s.y
    s.width
    s.height

{.push inline.}

func position*[T: SomeRect2](s: T): auto =
  (x: s.x, y: s.y)

func size*[T: SomeRect2](s: T): auto =
  (x: s.width, y: s.height)

func bottomLeft*[T: SomeRect2](s: T): auto =
  (x: s.x, y: s.y)

func bottomRight*[T: SomeRect2](s: T): auto =
  (x: s.x + s.width, y: s.y)

func topLeft*[T: SomeRect2](s: T): auto =
  (x: s.x, y: s.y + s.height)

func topRight*[T: SomeRect2](s: T): auto =
  (x: s.x + s.width, y: s.y + s.height)

func area*[T: SomeRect2](s: T): auto =
  s.width * s.height

func center*[T: SomeRect2](s: T): auto =
  (s.x + s.width * 0.5, s.y + s.height * 0.5)

func expand*[T: SomeRect2, B](s: var T, by: B) =
  s.x -= by
  s.y -= by
  let byX2 = by * 2
  s.width += byX2
  s.height += byX2

func expanded*[T: SomeRect2, B](s: T, by: B): T =
  result = s
  result.expand(by)

{.pop.}