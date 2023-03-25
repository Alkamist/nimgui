{.experimental: "overloadableEnums".}

# Figure out how to purge unused widgets from the table.

import std/sugar
# import std/strformat
import nimgui

const fontData = readFile("consola.ttf")

let gui = newGui()
gui.backgroundColor = rgb(13, 17, 23)
gui.gfx.addFont("consola", fontData)
gui.gfx.font = "consola"

gui.onFrame:
  # gui.button(button4):
  #   button4.label = "Button 4"
  #   button4.position = vec2(20.0, 40.0)
  #   if button4.pressed:
  #     echo "Button 4 Pressed"

  # gui.window(window1):
  #   window1.title = "Window 1"
  #   gui.window(window2):
  #     window2.title = "Window 2"

  #     gui.button(button1):
  #       button1.label = "Button 1"
  #       button1.position = vec2(20.0, 40.0)
  #       if button1.pressed:
  #         echo "Button 1 Pressed"

  #     gui.button(button2):
  #       button2.label = "Button 2"
  #       button2.position = vec2(20.0, 70.0)
  #       if button2.pressed:
  #         echo "Button 2 Pressed"

  #     for row in 0 ..< 4:
  #       for col in 0 ..< 4:
  #         capture row, col:
  #           let i = row * 4 + col
  #           gui.button(button, i):
  #             button.label = "Button " & $i
  #             button.position = vec2(row.float * 120.0, col.float * 160.0)
  #             if button.pressed:
  #               echo "Button " & $i & " Pressed"

  gui.window(window1):
    window1.title = "Window"
    gui.window(childWindow):
      childWindow.title = "Child Window"
      gui.button(button1):
        button1.width = childWindow.width
        button1.position = vec2(5.0, 30.0)
        if button1.pressed:
          echo "Button 1 Pressed"

while gui.isOpen:
  gui.update()