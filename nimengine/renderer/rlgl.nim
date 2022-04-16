import std/strutils

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

{.compile: "rlgl/rlgl.c".}

const rlglHeader = currentSourceDir() & "/rlgl/rlgl.h"

type
  Matrix* {.importc, header: rlglHeader.} = object
    m0*, m4*, m8*, m12*: cfloat
    m1*, m5*, m9*, m13*: cfloat
    m2*, m6*, m10*, m14*: cfloat
    m3*, m7*, m11*, m15*: cfloat

  rlVertexBuffer* {.importc, header: rlglHeader.} = object
    elementCount*: cint
    vertices*: ptr cfloat
    texcoords*: ptr cfloat
    colors*: ptr uint8
    when defined(graphicsApiOpenGl11) or defined(graphicsApiOpenGl33):
      indices*: ptr cuint
    when defined(graphicsApiOpenGlEs2):
      indices*: ptr cushort
    vaoId*: cuint
    vboId*: array[4, cuint]

  rlDrawCall* {.importc, header: rlglHeader.} = object
    mode*: cint
    vertexCount*: cint
    vertexAlignment*: cint
    textureId*: cuint

  rlRenderBatch* {.importc, header: rlglHeader.} = object
    bufferCount*: cint
    currentBuffer*: cint
    vertexBuffer*: ptr rlVertexBuffer
    draws*: ptr rlDrawCall
    drawCounter*: cint
    currentDepth*: cfloat

const RL_LINES* = 0x0001.cint
const RL_TRIANGLES* = 0x0004.cint
const RL_QUADS* = 0x0007.cint

{.push importc, header: rlglHeader, discardable.}

proc rlMatrixMode*(mode: cint)
proc rlPushMatrix*()
proc rlPopMatrix*()
proc rlLoadIdentity*()
proc rlTranslatef*(x, y, z: cfloat)
proc rlRotatef*(angle, x, y, z: cfloat)
proc rlScalef*(x, y, z: cfloat)
proc rlMultMatrixf*(matf: ptr cfloat)
proc rlFrustum*(left, right, bottom, top, znear, zfar: cdouble)
proc rlOrtho*(left, right, bottom, top, znear, zfar: cdouble)
proc rlViewport*(x, y, width, height: cint)
proc rlBegin*(mode: cint)
proc rlEnd*()
proc rlVertex2i*(x, y: cint)
proc rlVertex2f*(x, y: cfloat)
proc rlVertex3f*(x, y, z: cfloat)
proc rlTexCoord2f*(x, y: cfloat)
proc rlNormal3f*(x, y, z: cfloat)
proc rlColor4ub*(r, g, b, a: uint8)
proc rlColor3f*(x, y, z: cfloat)
proc rlColor4f*(x, y, z, w: cfloat)
proc rlEnableVertexArray*(vaoId: cuint): bool
proc rlDisableVertexArray*()
proc rlEnableVertexBuffer*(id: cuint)
proc rlDisableVertexBuffer*()
proc rlEnableVertexBufferElement*(id: cuint)
proc rlDisableVertexBufferElement*()
proc rlEnableVertexAttribute*(index: cuint)
proc rlDisableVertexAttribute*(index: cuint)
proc rlEnableStatePointer*(vertexAttribType: cint, buffer: pointer)
proc rlDisableStatePointer*(vertexAttribType: cint)
proc rlActiveTextureSlot*(slot: cint)
proc rlEnableTexture*(id: cuint)
proc rlDisableTexture*()
proc rlEnableTextureCubemap*(id: cuint)
proc rlDisableTextureCubemap*()
proc rlTextureParameters*(id: cuint, param, value: cint)
proc rlEnableShader*(id: cuint)
proc rlDisableShader*()
proc rlEnableFramebuffer*(id: cuint)
proc rlDisableFramebuffer*()
proc rlActiveDrawBuffers*(count: cint)
proc rlEnableColorBlend*()
proc rlDisableColorBlend*()
proc rlEnableDepthTest*()
proc rlDisableDepthTest*()
proc rlEnableDepthMask*()
proc rlDisableDepthMask*()
proc rlEnableBackfaceCulling*()
proc rlDisableBackfaceCulling*()
proc rlEnableScissorTest*()
proc rlDisableScissorTest*()
proc rlScissor*(x, y, width, height: cint)
proc rlEnableWireMode*()
proc rlDisableWireMode*()
proc rlSetLineWidth*(width: cfloat)
proc rlGetLineWidth*(): cfloat
proc rlEnableSmoothLines*()
proc rlDisableSmoothLines*()
proc rlEnableStereoRender*()
proc rlDisableStereoRender*()
proc rlIsStereoRenderEnabled*(): bool
proc rlClearColor*(r, g, b, a: uint8)
proc rlClearScreenBuffers*()
proc rlCheckErrors*()
proc rlSetBlendMode*(mode: cint)
proc rlSetBlendFactors*(glSrcFactor, glDstFactor, glEquation: cint)
proc rlglInit*(width, height: cint)
proc rlglClose*()
proc rlLoadExtensions*(loader: pointer)
proc rlGetVersion*(): cint
proc rlGetFramebufferWidth*(): cint
proc rlGetFramebufferHeight*(): cint
proc rlGetTextureIdDefault*(): cuint
proc rlGetShaderIdDefault*(): cuint
proc rlGetShaderLocsDefault*(): ptr cint
proc rlLoadRenderBatch*(numBuffers, bufferElements: cint): rlRenderBatch
proc rlUnloadRenderBatch*(batch: rlRenderBatch)
proc rlDrawRenderBatch*(batch: ptr rlRenderBatch)
proc rlSetRenderBatchActive*(batch: ptr rlRenderBatch)
proc rlDrawRenderBatchActive*()
proc rlCheckRenderBatchLimit*(vCount: cint): bool
proc rlSetTexture*(id: cuint)
proc rlLoadVertexArray*(): cuint
proc rlLoadVertexBuffer*(buffer: pointer, size: cint, dynamic: bool): cuint
proc rlLoadVertexBufferElement*(buffer: pointer, size: cint, dynamic: bool): cuint
proc rlUpdateVertexBuffer*(bufferId: cuint, data: pointer, dataSize, offset: cint)
proc rlUpdateVertexBufferElements*(id: cuint, data: pointer, dataSize, offset: cint)
proc rlUnloadVertexArray*(vaoId: cuint)
proc rlUnloadVertexBuffer*(vboId: cuint)
proc rlSetVertexAttribute*(index: cuint, compSize, `type`: cint, normalized: bool, stride: cint, pointer: pointer)
proc rlSetVertexAttributeDivisor*(index: cuint, divisor: cint)
proc rlSetVertexAttributeDefault*(locIndex: cint, value: pointer, attribType, count: cint)
proc rlDrawVertexArray*(offset, count: cint)
proc rlDrawVertexArrayElements*(offset, count: cint, buffer: pointer)
proc rlDrawVertexArrayInstanced*(offset, count, instances: cint)
proc rlDrawVertexArrayElementsInstanced*(offset, count: cint, buffer: pointer, instances: cint)
proc rlLoadTexture*(data: pointer, width, height, format, mipmapCount: cint): cuint
proc rlLoadTextureDepth*(width, height: cint, useRenderBuffer: bool): cuint
proc rlLoadTextureCubemap*(data: pointer, size, format: cint): cuint
proc rlUpdateTexture*(id: cuint, offsetX, offsetY, width, height, format, data: pointer)
proc rlGetGlTextureFormats*(format: cint, glInternalFormat: ptr cint, glFormat: ptr cint, glType: ptr cint)
proc rlGetPixelFormatName*(format: cuint): cstring
proc rlUnloadTexture*(id: cuint)
proc rlGenTextureMipmaps*(id: cuint, width, height, format: cint, mipmaps: ptr cint)
proc rlReadTexturePixels*(id: cuint, width, height, format: cint): pointer
proc rlReadScreenPixels*(width, height: cint): ptr uint8
proc rlLoadFramebuffer*(width, height: cint): cuint
proc rlFramebufferAttach*(fboId: cuint, texId: cuint, attachType, texType, mipLevel: cint)
proc rlFramebufferComplete*(id: cuint): bool
proc rlUnloadFramebuffer*(id: cuint)
proc rlLoadShaderCode*(vsCode, fsCode: cstring): cuint
proc rlCompileShader*(shaderCode: cstring, `type`: cint): cuint
proc rlLoadShaderProgram*(vShaderId: cuint, fShaderId: cuint): cuint
proc rlUnloadShaderProgram*(id: cuint)
proc rlGetLocationUniform*(shaderId: cuint, uniformName: cstring): cint
proc rlGetLocationAttrib*(shaderId: cuint, attribName: cstring): cint
proc rlSetUniform*(locIndex: cint, value: pointer, uniformType, count: cint)
proc rlSetUniformMatrix*(locIndex: cint, mat: Matrix)
proc rlSetUniformSampler*(locIndex: cint, textureId: cuint)
proc rlSetShader*(id: cuint, locs: ptr cint)
proc rlLoadComputeShaderProgram*(shaderId: cuint): cuint
proc rlComputeShaderDispatch*(groupX, groupY, groupZ: cuint)
proc rlLoadShaderBuffer*(size: culonglong, data: pointer, usageHint: cint): cuint
proc rlUnloadShaderBuffer*(ssboId: cuint)
proc rlUpdateShaderBufferElements*(id: cuint, data: pointer, dataSize, offset: culonglong)
proc rlGetShaderBufferSize*(id: cuint): culonglong
proc rlReadShaderBufferElements*(id: cuint, dest: pointer, count, offset: culonglong)
proc rlBindShaderBuffer*(id, index: cuint)
proc rlCopyBuffersElements*(destId, srcId: cuint, destOffset, srcOffset, count: culonglong)
proc rlBindImageTexture*(id, index, format: cuint, readonly: cint)
proc rlGetMatrixModelview*(): Matrix
proc rlGetMatrixProjection*(): Matrix
proc rlGetMatrixTransform*(): Matrix
proc rlGetMatrixProjectionStereo*(eye: cint): Matrix
proc rlGetMatrixViewOffsetStereo*(eye: cint): Matrix
proc rlSetMatrixProjection*(proj: Matrix)
proc rlSetMatrixModelview*(view: Matrix)
proc rlSetMatrixProjectionStereo*(right: Matrix, left: Matrix)
proc rlSetMatrixViewOffsetStereo*(right: Matrix, left: Matrix)
proc rlLoadDrawCube*()
proc rlLoadDrawQuad*()

{.pop.}