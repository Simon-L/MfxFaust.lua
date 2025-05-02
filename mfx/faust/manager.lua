-- mfx/faust/manager.lua

local ffi = require "ffi"
local ig = require "imgui.sdl"
local json = require "rxi-json-lua"
local inspect = require "inspect"
local M = {}

local ui = require "mfx.ui.builder"
local lib = require "mfx.lib"

local math = require "math"

local function define_button_helpers(app)
  local function button_pressed(name)
    ig.Button(name)
  end

  local function button_released(name)
    ig.BeginDisabled(true)
    ig.Button(name)
    ig.EndDisabled()
  end

  function app:button(name)
    if self.buttons_states[name] == 1 then
      button_pressed(name)
    else
      button_released(name)
    end
  end
end

local function build_ui(app)
  for _, element in ipairs(ui.faust_ui_tbl) do
    local t, ptr = element.type, element.pointer
    if t == "addHorizontalSlider" then
      ig.SliderFloat(element.label, ptr, element.min, element.max)
    elseif t == "addHorizontalBargraph" then
      ig.BeginDisabled(true)
      ig.SliderFloat(element.label, ptr, element.min, element.max)
      ig.EndDisabled()
    elseif t == "addVerticalSlider" then
      ig.VSliderFloat(element.label, ig.ImVec2(40, 110), ptr, element.min, element.max)
    elseif t == "addVerticalBargraph" then
      ig.BeginDisabled(true)
      ig.VSliderFloat(element.label, ig.ImVec2(40, 110), ptr, element.min, element.max)
      ig.EndDisabled()
    elseif t == "addButton" then
      ig.Button(element.label)
      if ig.IsItemClicked() and ig.IsItemActive() then ptr[0] = 1.0 end
      if ig.IsMouseReleased(0) and ig.IsItemHovered() then ptr[0] = 0.0 end
    elseif t == "addCheckButton" then
      local b = ffi.new("bool[1]", ptr[0] > 0.5)
      if ig.Checkbox(element.label, b) then ptr[0] = b[0] and 1.0 or 0.0 end
    end
  end
end

function M.setup_app(app)
  define_button_helpers(app)

  function app:dump_faust_ui()
    local json_data = {}
    for _, e in ipairs(ui.faust_ui_tbl) do
      print(inspect(e))
    end
  end

  function app:add_faust_ui()
    build_ui(app)
  end

  function app:init(dsp_path)
    self.dsp_path = dsp_path
  end

  function app:reset_scope()
    for i = 0, 15 do
      ffi.C.memset(self.scope_buffer[i], 0, ffi.sizeof("float") * 48000)
    end
  end

  function app:start_dsp()
    -- self.MfxFaustLib = ffi.load(os.getenv("QUIRK_DEVICE") and "./libMfxFaust.aarch64-jelos.so" or "./libMfxFaust.x86_64.so")
    self.MfxFaustLib = ffi.load("libMfxFaust.so")
    local argc, argv
    if self.faust_include == nil then
      argc = 0
      argv = nil
    else
      argc = 2
      argv = ffi.new("const char*[?]", 2, {"-I", self.faust_include})
    end
    self.dsp = self.MfxFaustLib.lua_newDspfaust(self.dsp_path, self.error_msg, 48000, 512, argc, argv)
    if self.dsp == nil then
      print("error", ffi.string(self.error_msg))
      self.running = false
      return
    end
    local rb_size = bit.lshift(1, 21)
    self.rb = self.MfxFaustLib.mfx_ringbuffer_create(rb_size)
    self.MfxFaustLib.lua_setRingbuffer(self.dsp, self.rb)
    self.MfxFaustLib.lua_buildCLuaInterface(self.dsp, ui.faust_ui)

    self.key_triggers = {}
    for _, v in ipairs(ui.faust_ui_tbl) do
      if v.label and v.label:match("^[AZYERT]$") then
        self.key_triggers[v.label] = false
      end
    end

    self.MfxFaustLib.lua_startDspfaust(self.dsp)
    self.running = true
    -- self.memory = self.MfxFaustLib.lua_getDspMemory(self.dsp)
    self.total_samples_read = 0
    self.scope_trigger = false
    self.halted = false
    self.scope_buffer = ffi.new("float[16][48000]")
  end

  function app:stop_dsp()
    -- local MfxFaustLib = ffi.C
    self.MfxFaustLib.lua_stopDspfaust(self.dsp)
    self.MfxFaustLib.mfx_ringbuffer_free(self.rb)
    self.running = false
  end
end

function M.load(app, dsp_path, faust_include)
  app.error_msg = ffi.new("char[2048]")
  local fw = require("mfx.lib").FileWatcher(dsp_path)
  app.fw = fw
  app.faust_include = faust_include
  app:init(dsp_path)
  app:start_dsp()
  app:dump_faust_ui()
  print("getName", app:getName())
  -- app:init_sdl()
  -- app:init_imgui()
  -- require("imgui.sdl").ImPlot_CreateContext()
end

return M
