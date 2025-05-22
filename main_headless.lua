-- main.lua - Entry point

package.path = "./?.lua;prefix/share/lua/5.1/?.lua;prefix/share/lua/5.1/?/init.lua"
if jit.os ~= "Windows" then
  package.cpath = "./?.so;prefix/lib/lua/5.1/?.so;prefix/lib/lua/5.1/loadall.so"
else
  package.cpath = "./?.dll;prefix/lib/lua/5.1/?.dll;prefix/lib/lua/5.1/loadall.dll"
end

local ffi = require "ffi"
local inspect = require "inspect"
local app = require "pl.app"

local MFXApp = require "mfx.MFXApp"
local ui_builder = require "mfx.ui.builder"
-- local input_handler = require "mfx.input.handler"
local faust_manager = require "mfx.faust.manager"
local cli = require "mfx.cli"

-- Initialize app
local faust_app = MFXApp("Faust_1")
faust_manager.setup_app(faust_app)

local flags, params = cli.parse_args(arg)
local dsp_path = params[1]
faust_manager.load(faust_app, dsp_path, flags.I)
print("Press Ctrl+C to exit...")

while true do
    local fw = faust_app.fw
    if fw:has_changed() then
        faust_app:restart_dsp()
    end
    sleep(0.2)
end

faust_app:stop_dsp()
