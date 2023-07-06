type
  Performance* = object
    index: int
    deltaTimes: seq[float]
    currentFrameTime: float
    previousAverageWindow: int

proc frameTime*(performance: Performance): float =
  performance.currentFrameTime

proc fps*(performance: Performance): float =
  1.0 / performance.currentFrameTime

proc update*(performance: var Performance, deltaTime: float, averageWindow = 100) =
  if averageWindow != performance.previousAverageWindow:
    performance.index = 0
    performance.deltaTimes = newSeq[float](averageWindow)

  performance.deltaTimes[performance.index] = deltaTime
  performance.index += 1
  if performance.index >= performance.deltaTimes.len:
    performance.index = 0

  performance.currentFrameTime = 0.0

  for dt in performance.deltaTimes:
    performance.currentFrameTime += dt

  performance.currentFrameTime /= float(averageWindow)
  performance.previousAverageWindow = averageWindow