import ../gui

type
  Performance* = ref object of Widget
    frameTime*: float
    averageWindow*: int
    index: int
    deltaTimes: seq[float]
    previousAverageWindow: int

proc init*(perf: Performance) =
  perf.averageWindow = 100
  perf.deltaTimes = newSeq[float](100)

proc fps*(perf: Performance): float =
  1.0 / perf.frameTime

proc update*(perf: Performance) =
  let gui = perf.gui
  let averageWindow = perf.averageWindow

  if averageWindow != perf.previousAverageWindow:
    perf.index = 0
    perf.deltaTimes = newSeq[float](averageWindow)

  if perf.index < perf.deltaTimes.len:
    perf.deltaTimes[perf.index] = gui.deltaTime

  perf.index += 1
  if perf.index >= perf.deltaTimes.len:
    perf.index = 0

  perf.frameTime = 0.0

  for dt in perf.deltaTimes:
    perf.frameTime += dt

  perf.frameTime /= float(averageWindow)
  perf.previousAverageWindow = averageWindow