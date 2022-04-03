import pkg/opengl

type
  # Uniform3fv* = array[3, float32]
  # UniformMatrix4fv* = array[4, array[4, float32]]

  Uniform3fv* = concept v
    v[0] is float32
    v[1] is float32
    v[2] is float32

  UniformMatrix4fv* = concept m
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

  Shader* = object
    id*: GLuint

proc compileShaderSrc(kind: Glenum, source: string): GLuint =
  result = glCreateShader(kind)
  let src = allocCStringArray([source])
  glShaderSource(result, 1, src, nil)
  glCompileShader(result)
  deallocCStringArray(src)
  var compiledOk: GLint
  glGetShaderiv(result, GL_COMPILE_STATUS, compiledOk.addr)
  if compiledOk.Glboolean == GL_FALSE:
    var length: GLint
    glGetShaderiv(result, GL_INFO_LOG_LENGTH, length.addr)
    var message = newString(length)
    glGetShaderInfoLog(result, length, length.addr, message.cstring)
    glDeleteShader(result)
    raise newException(IOError, "Failed to compile shader: " & $message)

proc select*(shader: Shader) =
  glUseProgram(shader.id)

proc setUniform*(shader: Shader, name: string, value: Uniform3fv) =
  shader.select()
  glUniform3fv(
    glGetUniformLocation(shader.id, name),
    1,
    cast[ptr GLfloat](value.unsafeAddr),
  )

proc setUniform*(shader: Shader, name: string, value: UniformMatrix4fv) =
  shader.select()
  glUniformMatrix4fv(
    glGetUniformLocation(shader.id, name),
    1, GL_FALSE,
    cast[ptr GLfloat](value.unsafeAddr),
  )

proc `=destroy`*(shader: var Shader) =
  glDeleteProgram(shader.id)

proc init*(_: type Shader, vertexSource, fragmentSource: string): Shader =
  result.id = glCreateProgram()

  var vertexId = compileShaderSrc(GL_VERTEX_SHADER, vertexSource)
  var fragmentId = compileShaderSrc(GL_FRAGMENT_SHADER, fragmentSource)

  glAttachShader(result.id, vertexId)
  glAttachShader(result.id, fragmentId)

  glLinkProgram(result.id)
  glValidateProgram(result.id)

  glDeleteShader(vertexId)
  glDeleteShader(fragmentId)