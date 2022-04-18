import pkg/opengl
import ./concepts

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

proc setUniform*(shader: Shader, name: string, value: SomeUniform3fv) =
  shader.select()
  glUniform3fv(
    glGetUniformLocation(shader.id, name),
    1,
    cast[ptr GLfloat](value.unsafeAddr),
  )

proc setUniform*(shader: Shader, name: string, value: SomeUniformMatrix4fv) =
  shader.select()
  glUniformMatrix4fv(
    glGetUniformLocation(shader.id, name),
    1, GL_FALSE,
    cast[ptr GLfloat](value.unsafeAddr),
  )

proc `=destroy`*(shader: var Shader) =
  glDeleteProgram(shader.id)

proc initShader*(vertexSource, fragmentSource: string): Shader =
  result.id = glCreateProgram()

  var vertexId = compileShaderSrc(GL_VERTEX_SHADER, vertexSource)
  var fragmentId = compileShaderSrc(GL_FRAGMENT_SHADER, fragmentSource)

  glAttachShader(result.id, vertexId)
  glAttachShader(result.id, fragmentId)

  glLinkProgram(result.id)
  glValidateProgram(result.id)

  glDeleteShader(vertexId)
  glDeleteShader(fragmentId)