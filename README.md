# MarteauFX with Faust

![https://i.imgur.com/JqxMGsE.png](https://i.imgur.com/JqxMGsE.png)

> An environment to prototype Faust dsp, with live recompiling, oscilloscope view, hot reloading, soundfile and MIDI.

Run `install.sh` in an empty directory.  
Then run `run.sh` like this:  
```
LUA_PREFIX=<path where install.sh ran> ./run.sh ./main.lua [optional path to a .dsp file] -I=<path to faustlibraries>
```  
If no .dsp file was provided, a dialog will open.

Linux x86_64 (pipewire-jack required) and windows x64 (built-in rtaudio) should be good to go, Linux arm64 is highest priority, MacOS should be working too with limited changes.

This repository contains the high level Lua code used to load the dsp and show the gui (using ImGui-LuaJIT), the `install.sh` script assembles the needed pieces:
 - Faust built with LLVM support: [faust-for-mfx](https://github.com/Simon-L/faust-for-mfx)
 - libMfxFaust, a shared library providing a C wrapper with a simple API to run dynamic Faust dsp with the LLVM backend, statically linking faust with LLVM from the previous step: [libMfxFaust](https://github.com/Simon-L/libMfxFaust)
 - a Lua cross-platform standalone application base structure that provides everything to start writing Lua code, with ImGui for GUI: [mfx-base-app](https://github.com/Simon-L/mfx-base-app)