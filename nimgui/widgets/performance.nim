import ../gui

type
  Performance = object
    index: int
    deltaTimes: seq[float]
    currentFrameTime: float
    previousAverageWindow: int

proc update(perf: var Performance, deltaTime: float, averageWindow: int) =
  if averageWindow != perf.previousAverageWindow:
    perf.index = 0
    perf.deltaTimes = newSeq[float](averageWindow)

  perf.deltaTimes[perf.index] = deltaTime
  perf.index += 1
  if perf.index >= perf.deltaTimes.len:
    perf.index = 0

  perf.currentFrameTime = 0.0

  for dt in perf.deltaTimes:
    perf.currentFrameTime += dt

  perf.currentFrameTime /= float(averageWindow)
  perf.previousAverageWindow = averageWindow

proc frameTime*(gui: Gui, averageWindow = 100, update = true): float =
  let id = gui.getId("GUI_PERFORMANCE", global = true)
  var perf = gui.getState(id, Performance())

  if update:
    perf.update(gui.deltaTime, averageWindow)
    gui.setState(id, perf)

  perf.currentFrameTime

proc fps*(gui: Gui, averageWindow = 100, update = true): float =
  1.0 / gui.frameTime(averageWindow, update)