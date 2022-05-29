# Nim Canvas

This is just my silly attempt to unify windowing and gpu accelerated graphics in a simple way with Nim. It currently only works for Windows, but I want to get it working for other platforms such as WebAssembly, OSX, and Linux. I am changing this constantly so it's probably best not to use it for anything.

The Canvas object currently is an abstraction over both the Win32 api and [NanoVG](https://github.com/memononen/nanovg).