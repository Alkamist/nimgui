{.experimental: "dotOperators".}

import std/hashes
import std/tables

type
  GuiState = ref object of RootObj
    root* {.cursor.}: GuiNode
    parent* {.cursor.}: GuiNode
    name*: string
    init*: bool

  GuiNode* = ref object of GuiState
    state*: Table[string, GuiState]
    activeState*: seq[GuiState]

proc getState*(node: GuiNode, name: string, T: typedesc): T =
  if node.state.hasKey(name):
    result = T(node.state[name])
    result.init = false
  else:
    result = T()
    result.root = node.root
    result.parent = node
    result.init = true
    result.name = name
    node.state[name] = result

proc getNode*(node: GuiNode, name: string): GuiNode =
  node.getState(name, GuiNode)

proc new*(_: typedesc[GuiNode]): GuiNode =
  result = GuiNode()
  result.root = result
  result.name = "root"
  result.init = true

proc fullName*(state: GuiState): string =
  if state.parent == nil:
    state.name
  else:
    state.parent.fullName & "." & state.name

let a = GuiNode.new()
let b = a.getNode("b")

type
  Foo = ref object of GuiState
    value: bool

let foo = b.getState("foo", Foo)
foo.value = true

echo foo.fullName
echo foo.value