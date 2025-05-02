package = "mfx-faust"
version = "dev-1"

source = {
  url = "git+https://github.com/Simon-L/MfxFaust.lua.git"
}

description = {
  summary = "Modular SDL/ImGui Faust DSP frontend",
  detailed = [[
    MFX Faust provides a Lua-based modular frontend for interacting
    with Faust DSP engines using SDL2, ImGui, and custom UI injection.
  ]],
  homepage = "https://github.com/Simon-L/MfxFaust.lua",
  license = "MIT"
}

dependencies = {
  "lua == 5.1",
  "luaposix",
  "luasocket",
  "penlight",
  "rxi-json-lua",
  "inspect"
}

build = {
  type = "builtin",
  modules = {
    ["mfx.MFXApp"]         = "mfx/MFXApp.lua",
    ["mfx.lib"]            = "mfx/lib.lua",
    ["mfx.ui.builder"]     = "mfx/ui/builder.lua",
    ["mfx.input.handler"]  = "mfx/input/handler.lua",
    ["mfx.faust.manager"]  = "mfx/faust/manager.lua",
    ["mfx.cli"]            = "mfx/cli.lua"
  }
}
