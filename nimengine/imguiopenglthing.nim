import pkg/opengl

type
  Vec2* = object
    x*, y*: float32

  Vec4* = object
    x*, y*, z*, w*: float32

  Color* = object
    r*, g*, b*, a*: uint8

  Renderer2d* = object
    glVersion*: GLuint
    # glslVersionString*: array[32, char]
    fontTexture*: GLuint
    shaderHandle*: GLuint
    attribLocationTex*: GLint
    attribLocationProjMtx*: GLint
    attribLocationVtxPos*: GLuint
    attribLocationVtxUV*: GLuint
    attribLocationVtxColor*: GLuint
    vboHandle, elementsHandle*: GLuint
    vertexBufferSize*: GLsizeiptr
    indexBufferSize*: GLsizeiptr
    hasClipOrigin*: bool

  Vertex2d* = object
    position*: Vec2
    uv*: Vec2
    color*: Color

  Index2d* = uint16

  DrawCmd* = object
    clipRect*: Vec4
    textureId*: GLuint
    vtxOffset*: int
    idxOffset*: int
    elemCount*: int

  DrawList* = object
    cmdBuffer: seq[DrawCmd]
    idxBuffer*: seq[Index2d]
    vtxBuffer*: seq[Vertex2d]

  DrawData* = object
    drawLists*: seq[DrawList]
    displayPos*: Vec2
    displaySize*: Vec2
    framebufferScale*: Vec2

proc vec2*(x, y: float32): Vec2 =
  Vec2(x: x, y: y)

proc setupRenderState*(self: Renderer2d, drawData: DrawData, fbWidth, fbHeight: int, vertexArrayObject: GLuint) =
  glEnable(GL_BLEND)
  glBlendEquation(GL_FUNC_ADD)
  glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)
  glDisable(GL_STENCIL_TEST)
  glEnable(GL_SCISSOR_TEST)
  # if (self.glVersion >= 310)
  #   glDisable(GL_PRIMITIVE_RESTART)
  # glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

  glViewport(0, 0, fbWidth.GLsizei, fbHeight.GLsizei)

  let left = drawData.displayPos.x
  let right = drawData.displayPos.x + drawData.displaySize.x
  let top = drawData.displayPos.y
  let bottom = drawData.displayPos.y + drawData.displaySize.y
  var orthoProjection = [
    [2.0f / (right - left), 0.0f, 0.0f, 0.0f],
    [0.0f, 2.0f / (top - bottom), 0.0f, 0.0f],
    [0.0f, 0.0f, -1.0f, 0.0f],
    [(right + left) / (left - right), (top + bottom) / (bottom - top), 0.0f, 1.0f],
  ]

  glUseProgram(self.shaderHandle)
  glUniform1i(self.attribLocationTex, 0)
  glUniformMatrix4fv(self.attribLocationProjMtx, 1, GL_FALSE, cast[ptr GLfloat](orthoProjection.addr))

  # if self.GlVersion >= 330:
  #   glBindSampler(0, 0)

  glBindVertexArray(vertexArrayObject)

  glBindBuffer(GL_ARRAY_BUFFER, self.vboHandle)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.elementsHandle)
  glEnableVertexAttribArray(self.attribLocationVtxPos)
  glEnableVertexAttribArray(self.attribLocationVtxUV)
  glEnableVertexAttribArray(self.attribLocationVtxColor)
  glVertexAttribPointer(self.attribLocationVtxPos, 2, cGL_FLOAT, GL_FALSE, sizeof(Vertex2d).GLsizei, cast[pointer](offsetOf(Vertex2d, position)))
  glVertexAttribPointer(self.attribLocationVtxUV, 2, cGL_FLOAT, GL_FALSE, sizeof(Vertex2d).GLsizei, cast[pointer](offsetOf(Vertex2d, uv)))
  glVertexAttribPointer(self.attribLocationVtxColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(Vertex2d).GLsizei, cast[pointer](offsetOf(Vertex2d, color)))

proc render*(self: var Renderer2d, drawData: DrawData) =
  let fbWidth = (drawData.displaySize.x * drawData.framebufferScale.x).int
  let fbHeight = (drawData.displaySize.y * drawData.framebufferScale.y).int
  if fbWidth <= 0 or fbHeight <= 0:
    return

  var vertexArrayObject = 0.GLuint
  glGenVertexArrays(1, vertexArrayObject.addr)
  self.setupRenderState(drawData, fbWidth, fbHeight, vertexArrayObject)

  let clipOff = drawData.displayPos
  let clipScale = drawData.framebufferScale

  for n in 0 ..< drawData.drawLists.len:
    let drawList = drawData.drawLists[n]

    let vtxBufferSize = cast[GLsizeiptr](drawList.vtxBuffer.len * sizeof(Vertex2d))
    let idxBufferSize = cast[GLsizeiptr](drawList.idxBuffer.len * sizeof(Index2d))
    if self.vertexBufferSize < vtxBufferSize:
      self.vertexBufferSize = vtxBufferSize
      glBufferData(GL_ARRAY_BUFFER, self.vertexBufferSize, nil, GL_STREAM_DRAW)

    if self.indexBufferSize < idxBufferSize:
      self.indexBufferSize = idxBufferSize
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferSize, nil, GL_STREAM_DRAW)

    glBufferSubData(GL_ARRAY_BUFFER, 0, vtxBufferSize, drawList.vtxBuffer.unsafeAddr)
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, idxBufferSize, drawList.idxBuffer.unsafeAddr)

    for cmdI in 0 ..< drawList.cmdBuffer.len:
      let cmd = drawList.cmdBuffer[cmdI]

      let clipMin = vec2((cmd.clipRect.x - clipOff.x) * clipScale.x, (cmd.clipRect.y - clipOff.y) * clipScale.y)
      let clipMax = vec2((cmd.clipRect.z - clipOff.x) * clipScale.x, (cmd.clipRect.w - clipOff.y) * clipScale.y)
      if clipMax.x <= clipMin.x or clipMax.y <= clipMin.y:
        continue

      glScissor(clipMin.x.GLint, (fbHeight.float32 - clipMax.y).GLint, (clipMax.x - clipMin.x).GLsizei, (clipMax.y - clipMin.y).GLsizei)

      glBindTexture(GL_TEXTURE_2D, cmd.textureId)

      let indexKind =
        if sizeof(Index2d) == 2:
          GL_UNSIGNED_SHORT
        else:
          GL_UNSIGNED_INT

      glDrawElementsBaseVertex(GL_TRIANGLES, cmd.elemCount.GLsizei, indexKind, cast[pointer](cmd.idxOffset * sizeof(Index2d)), cmd.vtxOffset.GLint)
      glDrawElements(GL_TRIANGLES, cmd.elemCount.GLsizei, indexKind, cast[pointer](cmd.idxOffset * sizeof(Index2d)))

  glDeleteVertexArrays(1, vertexArrayObject.addr)