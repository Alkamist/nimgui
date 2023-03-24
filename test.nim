{.experimental: "overloadableEnums".}

# Figure out how to purge unused widgets from the table.

import std/strformat
import nimgui

const fontData = readFile("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", fontData)
gui.gfx.font = "consola"

import std/macros

gui.onFrame:
  # gui.window(window1):
    # window1.title = "Window 1"

  # gui.button(button1):
  #   button1.label = "Button 1"
  #   button1.position = vec2(5.0, 30.0)
  #   if button1.pressed:
  #     echo "Button 1 Pressed"

  # gui.button(button2):
  #   button2.label = "Button 2"
  #   button2.position = vec2(5.0, 70.0)
  #   if button2.pressed:
  #     echo "Button 2 Pressed"

  for i in 0 ..< 4:
    gui.button(button, i):
      button.label = "Button " & $i
      button.position = vec2(i.float * 120.0, 160.0)
      if button.pressed:
        echo "Button " & $i & " Pressed"



  # for i in 0 ..< 4:
  #   gui.button(button[i]):
  #     button.label = &"Button {i}"
  #     button.position = vec2(i.float * 120.0, 160.0)
  #     if button.pressed:
  #       echo &"Button {i} Pressed"

  # gui.window("Window 1"):
  #   gui.window("Window 2"):
  #     gui.button("Button 1"):
  #       # button.width = window.width
  #       button.position = vec2(5.0, 30.0)
  #       if button.pressed:
  #         echo "Button 1"

  #     gui.button("Button 2"):
  #       button.position = vec2(5.0, 70.0)
  #       if button.pressed:
  #         echo "Button 2"

while gui.isOpen:
  gui.update()