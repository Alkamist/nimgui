import std/math
import ./vec3
import ./basis

type
  Transform* = object
    basis*: Basis
    origin*: Vec3

{.push inline.}

func inverseXform*(a, b: Transform): Transform =
  let v = b.origin - a.origin
  result.basis = a.basis.transposeXform(b.basis)
  result.origin = a.basis.xform(v)

func set*(a: var Transform,
          xx, xy, xz: float32,
          yx, yy, yz: float32,
          zx, zy, zz: float32,
          tx, ty, tz: float32) =
  a.basis.set(xx, xy, xz, yx, yy, yz, zx, zy, zz)
  a.origin.x = tx
  a.origin.y = ty
  a.origin.z = tz

func xform*(a: Transform, b: Vec3): Vec3 =
  result.x = a.basis[0].dot(b) + a.origin.x
  result.y = a.basis[1].dot(b) + a.origin.y
  result.z = a.basis[2].dot(b) + a.origin.z

func xformInv*(a: Transform, b: Vec3): Vec3 =
  let v = b - a.origin
  result.x = (a.basis[0][0] * v.x) + (a.basis[1][0] * v.y) + (a.basis[2][0] * v.z)
  result.y = (a.basis[0][1] * v.x) + (a.basis[1][1] * v.y) + (a.basis[2][1] * v.z)
  result.z = (a.basis[0][2] * v.x) + (a.basis[1][2] * v.y) + (a.basis[2][2] * v.z)

func `*=`*(a: var Transform, b: Transform) =
  a.origin = a.xform(b.origin)
  a.basis *= b.basis

func `*`*(a, b: Transform): Transform =
  result = a
  result *= b

func `*=`*(a: var Transform, b: float) =
  a.origin *= b
  a.basis *= b

func `*`*(a: Transform, b: float): Transform =
  result = a
  result *= b

func `~=`*(a, b: Transform): bool =
  (a.basis ~= b.basis) and (a.origin ~= b.origin)

func `==`*(a, b: Transform): bool =
  (a.basis == b.basis) and (a.origin == b.origin)

func affineInvert*(a: var Transform) =
  a.basis.invert()
  a.origin = a.basis.xform(-a.origin)

func affineInverse*(a: Transform): Transform =
  result = a
  result.affineInvert()

func invert*(a: var Transform) =
  a.basis.transpose()
  a.origin = a.basis.xform(-a.origin)

func inverse*(a: Transform): Transform =
  ## This function assumes the basis is a rotation matrix, with no scaling.
  result = a
  result.invert()

func rotated*(a: Transform, axis: Vec3, angle: float): Transform =
  result.basis = basis(axis, angle)
  result.origin = vec3()
  result *= a

func rotate*(a: var Transform, axis: Vec3, angle: float) =
  a = a.rotated(axis, angle)

func rotateBasis*(a: var Transform, axis: Vec3, angle: float) =
  a.basis.rotate(axis, angle)

func lookingAt*(a: Transform, target, up: Vec3): Transform =
  result = a
  result.basis = a.basis.lookingAt(target - a.origin, up)

func setLookAt*(a: var Transform, eye, target, up: Vec3) =
  a.basis = a.basis.lookingAt(target - eye, up)
  a.origin = eye

func scale*(a: var Transform, scale: Vec3) =
  a.basis.scale(scale)
  a.origin *= scale

func scaled*(a: Transform, scale: Vec3): Transform =
  result = a
  result.scale(scale)

func scaleBasis*(a: var Transform, scale: Vec3) =
  a.basis.scale(scale)

func translate*(a: var Transform, v: Vec3) =
  for i in 0 ..< 3:
    a.origin[i] += a.basis[i].dot(v)

func translate*(a: var Transform, x, y, z: float) =
  a.translate(vec3(x, y, z))

func translated*(a: Transform, v: Vec3): Transform =
  result = a
  result.translate(v)

func orthonormalize*(a: var Transform) =
  a.basis.orthonormalize()

func orthonormalized*(a: Transform): Transform =
  result = a
  result.orthonormalize()

func transform*(): Transform =
  result.basis = basis()
  result.origin = vec3()

func transform*(basis: Basis, origin: Vec3): Transform =
  result.basis = basis
  result.origin = origin

func transform*(x, y, z, origin: Vec3): Transform =
  result.origin = origin
  result.basis.x = x
  result.basis.y = y
  result.basis.z = z

func transform*(xx, xy, xz: float32,
                yx, yy, yz: float32,
                zx, zy, zz: float32,
                tx, ty, tz: float32): Transform =
  result.set(xx, xy, xz, yx, yy, yz, zx, zy, zz, tx, ty, tz)

{.pop.}