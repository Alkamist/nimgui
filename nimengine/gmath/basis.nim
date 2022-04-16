import std/math
import ./vec3
import ./utils

type
  Basis* = object
    elements*: array[3, Vec3]

{.push inline.}

template `[]`*(a: Basis, i: int): untyped = a.elements[i]
template `[]=`*(a: Basis, i: int, v: Vec3): untyped = a.elements[i] = v

func getAxis*(a: Basis, i: int): Vec3 =
  result.x = a[0][i]
  result.y = a[1][i]
  result.z = a[2][i]

func setAxis*(a: var Basis, i: int, v: Vec3) =
  a[0][i] = v.x
  a[1][i] = v.y
  a[2][i] = v.z

template x*(a: Basis): untyped = a.getAxis(0)
template y*(a: Basis): untyped = a.getAxis(1)
template z*(a: Basis): untyped = a.getAxis(2)
template `x=`*(a: Basis, v: Vec3): untyped = a.setAxis(0, v)
template `y=`*(a: Basis, v: Vec3): untyped = a.setAxis(1, v)
template `z=`*(a: Basis, v: Vec3): untyped = a.setAxis(2, v)

func `$`*(a: Basis): string =
  "Basis:\n" &
  "  " & $a.x.x.prettyFloat & ", " & $a.x.y.prettyFloat & ", " & $a.x.z.prettyFloat & "\n" &
  "  " & $a.y.x.prettyFloat & ", " & $a.y.y.prettyFloat & ", " & $a.y.z.prettyFloat & "\n" &
  "  " & $a.z.x.prettyFloat & ", " & $a.z.y.prettyFloat & ", " & $a.z.z.prettyFloat & "\n"

func set*(a: var Basis, x, y, z: Vec3) =
  a.x = x
  a.y = y
  a.z = z

func set*(a: var Basis,
          xx, xy, xz: float32,
          yx, yy, yz: float32,
          zx, zy, zz: float32) =
  a[0][0] = xx
  a[0][1] = xy
  a[0][2] = xz
  a[1][0] = yx
  a[1][1] = yy
  a[1][2] = yz
  a[2][0] = zx
  a[2][1] = zy
  a[2][2] = zz

func setAxisAngle*(a: var Basis, axis: Vec3, angle: float) =
  assert(axis.isNormalized, "The rotation axis must be normalized.")

  let axisSquared = vec3(axis.x * axis.x, axis.y * axis.y, axis.z * axis.z)
  let cosine = angle.cos
  a[0][0] = axisSquared.x + cosine * (1.0 - axisSquared.x)
  a[1][1] = axisSquared.y + cosine * (1.0 - axisSquared.y)
  a[2][2] = axisSquared.z + cosine * (1.0 - axisSquared.z)

  let sine = angle.sin
  let t = 1.0 - cosine

  var xyzt = axis.x * axis.y * t
  var zyxs = axis.z * sine
  a[0][1] = xyzt - zyxs
  a[1][0] = xyzt + zyxs

  xyzt = axis.x * axis.z * t
  zyxs = axis.y * sine
  a[0][2] = xyzt + zyxs
  a[2][0] = xyzt - zyxs

  xyzt = axis.y * axis.z * t
  zyxs = axis.x * sine
  a[1][2] = xyzt - zyxs
  a[2][1] = xyzt + zyxs

func tDotX*(a: Basis, v: Vec3): float32 =
  a[0][0] * v[0] + a[1][0] * v[1] + a[2][0] * v[2]

func tDotY*(a: Basis, v: Vec3): float32 =
  a[0][1] * v[0] + a[1][1] * v[1] + a[2][1] * v[2]

func tDotZ*(a: Basis, v: Vec3): float32 =
  a[0][2] * v[0] + a[1][2] * v[1] + a[2][2] * v[2]

func `*=`*(a: var Basis, b: Basis) =
  a.set(
    b.tdotx(a[0]), b.tdoty(a[0]), b.tdotz(a[0]),
    b.tdotx(a[1]), b.tdoty(a[1]), b.tdotz(a[1]),
    b.tdotx(a[2]), b.tdoty(a[2]), b.tdotz(a[2]),
  )

func `*`*(a, b: Basis): Basis =
  result = a
  result *= b

func `+=`*(a: var Basis, b: Basis) =
  a[0] += b[0]
  a[1] += b[1]
  a[2] += b[2]

func `+`*(a, b: Basis): Basis =
  result = a
  result += b

func `-=`*(a: var Basis, b: Basis) =
  a[0] -= b[0]
  a[1] -= b[1]
  a[2] -= b[2]

func `-`*(a, b: Basis): Basis =
  result = a
  result -= b

func `*=`*(a: var Basis, value: float) =
  a[0] *= value
  a[1] *= value
  a[2] *= value

func `*`*(a: Basis, value: float): Basis =
  result = a
  result *= value

func `~=`*(a, b: Basis): bool =
  a[0] ~= b[0] and a[1] ~= b[1] and a[2] ~= b[2]

func basis*(): Basis =
  result[0] = vec3(1.0, 0.0, 0.0)
  result[1] = vec3(0.0, 1.0, 0.0)
  result[2] = vec3(0.0, 0.0, 1.0)

func basis*(row0, row1, row2: Vec3): Basis =
  result[0] = row0
  result[1] = row1
  result[2] = row2

func basis*(xx, xy, xz: float32,
            yx, yy, yz: float32,
            zx, zy, zz: float32): Basis =
  result.set(xx, xy, xz, yx, yy, yz, zx, zy, zz)

func basis*(axis: Vec3, angle: float): Basis =
  result.setAxisAngle(axis, angle)

func getColumn*(a: Basis, i: int): Vec3 =
  a.getAxis(i)

func getRow*(a: Basis, i: int): Vec3 =
  result.x = a[i][0]
  result.y = a[i][1]
  result.z = a[i][2]

func setRow*(a: var Basis, i: int, v: Vec3) =
  a[i][0] = v.x
  a[i][1] = v.y
  a[i][2] = v.z

func getMainDiagonal*(a: Basis): Vec3 =
  result.x = a[0][0]
  result.y = a[1][1]
  result.z = a[2][2]

func setZero*(a: var Basis): Vec3 =
  a[0].setZero()
  a[1].setZero()
  a[2].setZero()

func xform*(a: Basis, v: Vec3): Vec3 =
  result.x = a[0].dot(v)
  result.y = a[1].dot(v)
  result.z = a[2].dot(v)

func xformInv*(a: Basis, v: Vec3): Vec3 =
  result.x = (a[0][0] * v.x) + (a[1][0] * v.y) + (a[2][0] * v.z)
  result.y = (a[0][1] * v.x) + (a[1][1] * v.y) + (a[2][1] * v.z)
  result.z = (a[0][2] * v.x) + (a[1][2] * v.y) + (a[2][2] * v.z)

func determinant*(a: Basis): float32 =
  a[0][0] * (a[1][1] * a[2][2] - a[2][1] * a[1][2]) -
  a[1][0] * (a[0][1] * a[2][2] - a[2][1] * a[0][2]) +
  a[2][0] * (a[0][1] * a[1][2] - a[1][1] * a[0][2])

func transposeXform*(a, b: Basis): Basis =
  result.set(
    a[0].x * b[0].x + a[1].x * b[1].x + a[2].x * b[2].x,
    a[0].x * b[0].y + a[1].x * b[1].y + a[2].x * b[2].y,
    a[0].x * b[0].z + a[1].x * b[1].z + a[2].x * b[2].z,
    a[0].y * b[0].x + a[1].y * b[1].x + a[2].y * b[2].x,
    a[0].y * b[0].y + a[1].y * b[1].y + a[2].y * b[2].y,
    a[0].y * b[0].z + a[1].y * b[1].z + a[2].y * b[2].z,
    a[0].z * b[0].x + a[1].z * b[1].x + a[2].z * b[2].x,
    a[0].z * b[0].y + a[1].z * b[1].y + a[2].z * b[2].y,
    a[0].z * b[0].z + a[1].z * b[1].z + a[2].z * b[2].z,
  )

func invert*(a: var Basis) =
  template cofac(row1, col1, row2, col2): untyped =
    (a[row1][col1] * a[row2][col2] - a[row1][col2] * a[row2][col1])

  let co = [
    cofac(1, 1, 2, 2), cofac(1, 2, 2, 0), cofac(1, 0, 2, 1)
  ]
  let det = a[0][0] * co[0] +
            a[0][1] * co[1] +
            a[0][2] * co[2]

  assert det != 0.0

  let s = 1.0 / det
  a.set(
    co[0] * s, cofac(0, 2, 2, 1) * s, cofac(0, 1, 1, 2) * s,
    co[1] * s, cofac(0, 0, 2, 2) * s, cofac(0, 2, 1, 0) * s,
    co[2] * s, cofac(0, 1, 2, 0) * s, cofac(0, 0, 1, 1) * s,
  )

func inverse*(a: Basis): Basis =
  result = a
  result.invert()

func orthonormalize*(a: var Basis) =
  var x = a.x
  var y = a.y
  var z = a.z
  x.normalize
  y = y - x * x.dot(y)
  y.normalize
  z = z - x * x.dot(z) - y * y.dot(z)
  z.normalize
  a.x = x
  a.y = y
  a.z = z

func orthonormalized*(a: Basis): Basis =
  result = a
  result.orthonormalize()

func transpose*(a: var Basis) =
  template swap(x, y): untyped =
    let temp = x
    x = y
    y = temp
  swap(a[0][1], a[1][0])
  swap(a[0][2], a[2][0])
  swap(a[1][2], a[2][1])

func transposed*(a: Basis): Basis =
  result = a
  result.transpose()

func isOrthogonal*(a: Basis): bool =
  let identity = basis()
  let m = a * a.transposed
  m ~= identity

func isDiagonal*(a: Basis): bool =
  a[0][1] ~= 0.0 and a[0][2] ~= 0.0 and
  a[1][0] ~= 0.0 and a[1][2] ~= 0.0 and
  a[2][0] ~= 0.0 and a[2][1] ~= 0.0

func isRotation*(a: Basis): bool =
  a.determinant ~= 1.0 and a.isOrthogonal

func isSymmetric*(a: Basis): bool =
  if not (a[0][1] ~= a[1][0]):
    return false
  if not (a[0][2] ~= a[2][0]):
    return false
  if not (a[1][2] ~= a[2][1]):
    return false
  true

func scale*(a: var Basis, scale: Vec3) =
  a[0][0] *= scale.x
  a[0][1] *= scale.x
  a[0][2] *= scale.x
  a[1][0] *= scale.y
  a[1][1] *= scale.y
  a[1][2] *= scale.y
  a[2][0] *= scale.z
  a[2][1] *= scale.z
  a[2][2] *= scale.z

func scaled*(a: Basis, scale: Vec3): Basis =
  result = a
  result.scale(scale)

func rotated*(a: Basis, axis: Vec3, angle: float): Basis =
  basis(axis, angle) * a

func rotate*(a: var Basis, axis: Vec3, angle: float) =
  a = a.rotated(axis, angle)

func rotatedLocal*(a: Basis, axis: Vec3, angle: float): Basis =
  a * basis(axis, angle)

func rotateLocal*(a: var Basis, axis: Vec3, angle: float) =
  a = a.rotatedLocal(axis, angle)

func lookingAt*(a: Basis, target, up: Vec3): Basis =
  let zero = vec3()
  assert(not (target ~= zero), "The target vector can't be zero.")
  assert(not (up ~= zero), "The up vector can't be zero.")
  let vz = -target.normalized
  var vx = up.cross(vz)
  assert(not (vx ~= zero), "The target vector and up vector can't be parallel to each other.")
  vx = vx.normalized
  let vy = vz.cross(vx)
  result.set(vx, vy, vz)

{.pop.}