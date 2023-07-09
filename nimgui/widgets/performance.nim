import ../gui

type
  Performance = object
    index: int
    deltaTimes: seq[float]
    currentFrameTime: float
    previousAverageWindow: int

proc update(performance: var Performance, deltaTime: float, averageWindow: int) =
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

proc frameTime*(gui: Gui, averageWindow = 100, update = true): float =
  let id = gui.getId("GUI_PERFORMANCE", global = true)
  var performance = gui.getState(id, Performance())

  if update:
    performance.update(gui.deltaTime, averageWindow)
    gui.setState(id, performance)

  performance.currentFrameTime

proc fps*(gui: Gui, averageWindow = 100, update = true): float =
  1.0 / gui.frameTime(averageWindow, update)