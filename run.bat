@echo off
set "LUA_PREFIX=z:\tmp\tmp.YAmrEMf2bt"

:: Get the directory of the first argument (the script to execute)
for %%I in ("%~1") do set "APP_PREFIX=%%~dpI?.lua"

:: Set environment variables for Lua paths
set "PATH=%LUA_PREFIX%\bin;%PATH%"
set "LUA_PATH=%APP_PREFIX%;.\?.lua;%LUA_PREFIX%\share\lua\5.1\?.lua;%LUA_PREFIX%\share\lua\5.1\?\init.lua"
set "LUA_CPATH=.\?.dll;%LUA_PREFIX%\lib\lua\5.1\?.dll;%LUA_PREFIX%\lib\lua\5.1\loadall.dll"

:: Run Lua interpreter with all original arguments
"%LUA_PREFIX%\bin\lua.exe" %*
set /p " = "