import std/random
import pkg/nimengine

let window = newWindow()
window.enableRenderer()
window.renderer.setBackgroundColor(0.1, 0.1, 0.1, 1.0)

var batch = newRenderBatch2d()
batch.reserveQuads(1024)

const randomTextureWidth = 64
const randomTextureHeight = 64
const randomTextureDataLen = randomTextureWidth * randomTextureHeight * 4
var randomTextureData: array[randomTextureDataLen, uint8]
for i in countup(0, randomTextureDataLen - 1, 4):
  randomTextureData[i] = rand(255).uint8
  randomTextureData[i + 1] = rand(255).uint8
  randomTextureData[i + 2] = rand(255).uint8
  randomTextureData[i + 3] = 255'u8

let randomTexture = newTexture()
randomTexture.upload(randomTextureWidth, randomTextureHeight, randomTextureData)

batch.onFlush = proc() =
  window.renderer.drawRenderBatch2d(batch, randomTexture)
  # window.renderer.drawRenderBatch2d(batch)

window.renderer.onRender2d = proc() =
  let w = window.width / 5
  let h = window.height / 5
  for i in 0 ..< 5:
    for j in 0 ..< 5:
      let x = i.float * w
      let y = j.float * h
      let rect = (x, y, w * 0.9, h * 0.9)
      let uv = (0.0, 0.0, 1.0, 1.0)
      let color = rgba(0.25, 0.25, 0.25, 1.0)
      batch.fillRect(rect, uv, color)
      batch.strokeRect(
        rect, uv,
        color.lightened(0.5),
        3.0,
      )
  batch.flush()

while not window.isClosed:
  window.update()