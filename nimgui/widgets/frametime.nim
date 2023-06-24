import ../gui

type
  GuiFrameTimeState = ref object of GuiState
    index: int
    deltaTimes: seq[float]
    cachedValue: float

proc frameTime*(gui: Gui, averageWindow = 100): float =
  let state = gui.getGlobalState("GUIFRAMETIME", GuiFrameTimeState)

  if state.init:
    state.deltaTimes = newSeq[float](averageWindow)

  if state.firstAccessThisFrame:
    state.deltaTimes[state.index] = gui.deltaTime
    state.index += 1
    if state.index >= state.deltaTimes.len:
      state.index = 0

    state.cachedValue = 0.0

    for dt in state.deltaTimes:
      state.cachedValue += dt

    state.cachedValue /= float(averageWindow)

  state.cachedValue

proc fps*(gui: Gui, averageWindow = 100): float =
  1.0 / gui.frameTime(averageWindow)