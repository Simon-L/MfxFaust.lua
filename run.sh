#! /bin/bash

# LUA_PREFIX="/tmp/mfx-base-app-ubuntu-x86_64"
app_prefix="$(dirname $(realpath $1))/?.lua"

export LD_LIBRARY_PATH="$LUA_PREFIX/bin"
export LUA_PATH="$app_prefix;./?.lua;$LUA_PREFIX/share/lua/5.1/?.lua;$LUA_PREFIX/share/lua/5.1/?/init.lua"
export LUA_CPATH="./?.so;$LUA_PREFIX/lib/lua/5.1/?.so;$LUA_PREFIX/lib/lua/5.1/loadall.so"

chmod +x $LUA_PREFIX/bin/lua
pw-jack $LUA_PREFIX/bin/lua $@
