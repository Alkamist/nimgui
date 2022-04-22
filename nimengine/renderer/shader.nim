import pkg/opengl
import ./concepts

type
  Shader* = ref object
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
    raise newException(IOError, "Failed to compile self: " & $message)

proc select*(self: Shader) =
  glUseProgram(self.id)

proc setUniform*(self: Shader, name: string, value: SomeUniform3fv) =
  self.select()
  glUniform3fv(
    glGetUniformLocation(self.id, name),
    1,
    cast[ptr GLfloat](value.unsafeAddr),
  )

proc setUniform*(self: Shader, name: string, value: SomeUniformMatrix4fv) =
  self.select()
  glUniformMatrix4fv(
    glGetUniformLocation(self.id, name),
    1, GL_FALSE,
    cast[ptr GLfloat](value.unsafeAddr),
  )

proc `=destroy`*(self: var type Shader()[]) =
  glDeleteProgram(self.id)

proc newShader*(vertexSource, fragmentSource: string): Shader =
  result = Shader(id: glCreateProgram())

  var vertexId = compileShaderSrc(GL_VERTEX_SHADER, vertexSource)
  var fragmentId = compileShaderSrc(GL_FRAGMENT_SHADER, fragmentSource)

  glAttachShader(result.id, vertexId)
  glAttachShader(result.id, fragmentId)

  glLinkProgram(result.id)
  glValidateProgram(result.id)

  glDeleteShader(vertexId)
  glDeleteShader(fragmentId)