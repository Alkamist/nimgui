import pkg/opengl
export opengl

type
  OpenGlState* = object
    activeTexture*: GLenum
    program*: GLuint
    texture*: GLuint
    sampler*: GLuint
    arrayBuffer*: GLuint
    vertexArrayObject*: GLuint
    polygonMode*: array[2, GLint]
    viewport*: array[4, GLint]
    scissorBox*: array[4, GLint]
    blendSrcRgb*: GLenum
    blendDstRgb*: GLenum
    blendSrcAlpha*: GLenum
    blendDstAlpha*: GLenum
    blendEquationRgb*: GLenum
    blendEquationAlpha*: GLenum
    blendIsEnabled*: GLboolean
    cullFaceIsEnabled*: GLboolean
    depthTestIsEnabled*: GLboolean
    stencilTestIsEnabled*: GLboolean
    scissorTestIsEnabled*: GLboolean
    primitiveRestartIsEnabled*: GLboolean

# proc getOpenGlVersion(): GLuint =
#   var major = 0.GLint
#   var minor = 0.GLint
#   glGetIntegerv(GL_MAJOR_VERSION, major.addr)
#   glGetIntegerv(GL_MINOR_VERSION, minor.addr)
#   if major == 0 and minor == 0:
#     # Query GL_VERSION in desktop GL 2.x, the string will start with "<major>.<minor>"
#     var glVersion = cast[cstring](glGetString(GL_VERSION))
#     sscanf(glVersion, "%d.%d", major.addr, minor.addr)
#   cast[GLuint](major * 100 + minor * 10)

proc getCurrentOpenGlState*(): OpenGlState =
  result = OpenGlState()
  glGetIntegerv(GL_ACTIVE_TEXTURE, cast[ptr GLint](result.activeTexture.addr))
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](result.program.addr))
  # glGetIntegerv(GL_TEXTURE_BINDING_2D, cast[ptr GLint](result.texture)) # Crashes on my system for some reason.

  # if result.openGlVersion >= 330:
  #   glGetIntegerv(GL_SAMPLER_BINDING, cast[ptr GLint](result.sampler.addr))
  # else:
  #   result.sampler = 0

  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, cast[ptr GLint](result.arrayBuffer.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](result.vertexArrayObject.addr)) # Not supported on ES2/WebGL1.

  when not defined(emscripten):
    glGetIntegerv(GL_POLYGON_MODE, cast[ptr GLint](result.polygonMode.addr))

  glGetIntegerv(GL_VIEWPORT, cast[ptr GLint](result.viewport.addr))
  glGetIntegerv(GL_SCISSOR_BOX, cast[ptr GLint](result.scissorBox.addr))
  glGetIntegerv(GL_BLEND_SRC_RGB, cast[ptr GLint](result.blendSrcRgb.addr))
  glGetIntegerv(GL_BLEND_DST_RGB, cast[ptr GLint](result.blendDstRgb.addr))
  glGetIntegerv(GL_BLEND_SRC_ALPHA, cast[ptr GLint](result.blendSrcAlpha.addr))
  glGetIntegerv(GL_BLEND_DST_ALPHA, cast[ptr GLint](result.blendDstAlpha.addr))
  glGetIntegerv(GL_BLEND_EQUATION_RGB, cast[ptr GLint](result.blendEquationRgb.addr))
  glGetIntegerv(GL_BLEND_EQUATION_ALPHA, cast[ptr GLint](result.blendEquationAlpha.addr))
  result.blendIsEnabled = glIsEnabled(GL_BLEND)
  result.cullFaceIsEnabled = glIsEnabled(GL_CULL_FACE)
  result.depthTestIsEnabled = glIsEnabled(GL_DEPTH_TEST)
  result.stencilTestIsEnabled = glIsEnabled(GL_STENCIL_TEST)
  result.scissorTestIsEnabled = glIsEnabled(GL_SCISSOR_TEST)

  # if result.openGlVersion >= 310:
  #   result.primitiveRestartIsEnabled = glIsEnabled(GL_PRIMITIVE_RESTART)
  # else:
  #   result.primitiveRestartIsEnabled = GL_FALSE

proc makeCurrent*(state: OpenGlState) =
  glUseProgram(state.program)
  glBindTexture(GL_TEXTURE_2D, state.texture)

  # if (state.openGlVersion >= 330):
  #   glBindSampler(0, state.sampler)
  # glActiveTexture(state.activeTexture) # Nim opengl doesn't seem to load this.

  glBindVertexArray(state.vertexArrayObject) # Not supported on ES2/WebGL1.
  glBindBuffer(GL_ARRAY_BUFFER, state.arrayBuffer)
  glBlendEquationSeparate(state.blendEquationRgb, state.blendEquationAlpha)
  glBlendFuncSeparate(state.blendSrcRgb, state.blendDstRgb, state.blendSrcAlpha, state.blendDstAlpha)
  if state.blendIsEnabled: glEnable(GL_BLEND) else: glDisable(GL_BLEND)
  if state.cullFaceIsEnabled: glEnable(GL_CULL_FACE) else: glDisable(GL_CULL_FACE)
  if state.depthTestIsEnabled: glEnable(GL_DEPTH_TEST) else: glDisable(GL_DEPTH_TEST)
  if state.stencilTestIsEnabled: glEnable(GL_STENCIL_TEST) else: glDisable(GL_STENCIL_TEST)
  if state.scissorTestIsEnabled: glEnable(GL_SCISSOR_TEST) else: glDisable(GL_SCISSOR_TEST)

  # if state.openGlVersion >= 310:
  #   if state.primitiveRestartIsEnabled:
  #     glEnable(GL_PRIMITIVE_RESTART)
  #   else:
  #     glDisable(GL_PRIMITIVE_RESTART)

  when not defined(emscripten):
    glPolygonMode(GL_FRONT_AND_BACK, cast[GLenum](state.polygonMode[0]))

  glViewport(state.viewport[0], state.viewport[1], state.viewport[2].GLsizei, state.viewport[3].GLsizei)
  glScissor(state.scissorBox[0], state.scissorBox[1], state.scissorBox[2].GLsizei, state.scissorBox[3].GLsizei)