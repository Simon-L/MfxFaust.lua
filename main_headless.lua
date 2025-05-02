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
print("1")
local faust_app = MFXApp("Faust_1")
print("2 mfxapp")
faust_manager.setup_app(faust_app)
print("3 setup_app")
-- input_handler.bind(faust_app)
print("4 bind")

local dsp_path = "test1.dsp"
faust_manager.load(faust_app, dsp_path, "/tmp/faust-for-mfx_master-dev_894bd3c/faustpfx/share/faust")
print("5 loaded")

-- Run main loop
-- print("6 press enter to stop")
-- faust_app:run()
-- io.read()
-- s = 1
-- print("7 will stop, sleep ", s, " and restart immediately")
-- faust_app:stop_dsp()
-- sleep(0.1)
-- while true do
--     local fw = faust_app.fw
--     if fw:has_changed() then
--         if faust_app.running then
--             faust_app:stop_dsp()
--             sleep(0.4)
--             print("stopped")
--         end
--         ui_builder.faust_ui_tbl = {}
--         faust_app.total_samples_read = 0
--         faust_app:reset_scope()
--         faust_app:start_dsp()
--         print("changed!!!")
--     end
-- a = io.read()
-- if a == 'q' then break end
-- end
sleep(1)
faust_app:stop_dsp()
sleep(1)
ui_builder.faust_ui_tbl = {}
faust_app.total_samples_read = 0
faust_app:reset_scope()
faust_app:start_dsp()
sleep(1)

-- io.read()
-- faust_app:start_dsp()
-- print("8 stopped and restarted, press enter to stop again")
-- io.read()
-- print("9")
faust_app:stop_dsp()
