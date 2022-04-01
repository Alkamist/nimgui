import pkg/opengl
import ./types

type
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

proc setUniform*(shader: Shader, name: string, value: FVec3Concept) =
  shader.select()
  var valueData = [value.x, value.y. value.z]
  glUniform3fv(
    glGetUniformLocation(shader.id, name),
    1,
    cast[ptr GLfloat](valueData.addr),
  )

proc setUniform*(shader: Shader, name: string, value: FMat4Concept) =
  shader.select()
  var valueData = [
    value[0][0], value[0][1], value[0][2], value[0][3],
    value[1][0], value[1][1], value[1][2], value[1][3],
    value[2][0], value[2][1], value[2][2], value[2][3],
    value[3][0], value[3][1], value[3][2], value[3][3],
  ]
  glUniformMatrix4fv(
    glGetUniformLocation(shader.id, name),
    1, GL_FALSE,
    cast[ptr GLfloat](valueData.addr),
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