-- main.lua - Entry point

if not os.getenv("LUA_PATH") then
  package.path = "./?.lua;prefix/share/lua/5.1/?.lua;prefix/share/lua/5.1/?/init.lua"
  if jit.os ~= "Windows" then
    package.cpath = "./?.so;prefix/lib/lua/5.1/?.so;prefix/lib/lua/5.1/loadall.so"
  else
    package.cpath = "./?.dll;prefix/lib/lua/5.1/?.dll;prefix/lib/lua/5.1/loadall.dll"
  end
end

local ffi = require "ffi"
local inspect = require "inspect"
local app = require "pl.app"

local MFXApp = require "mfx.MFXApp"
local ui_builder = require "mfx.ui.builder"
local input_handler = require "mfx.input.handler"
local faust_manager = require "mfx.faust.manager"
local cli = require "mfx.cli"

local ig = require"imgui.sdl"

-- Parse command-line args
local flags, params = cli.parse_args(arg)

-- Initialize app
local faust_app = MFXApp("Faust_1")
faust_manager.setup_app(faust_app)
input_handler.bind(faust_app)

-- Set DSP path from CLI
local dsp_path = params[1]
if dsp_path == nil then
  local dialog_dsp_path = ffi.new("char[2048]")
  if faust_app.MfxFaustLib.openDspDialog(dialog_dsp_path) then
    dsp_path = ffi.string(dialog_dsp_path)
  end
end
faust_manager.load(faust_app, dsp_path, flags.I)

faust_app:init_gui()

faust_app.scope_buffer = ffi.new("float[" .. 16 .. "][" .. 48000 .. "]")

local scope_length = ffi.new("int[1]", 48000)
local foo = scope_length[0] * 1.0

local done = false;

faust_app.total_samples_read = 0
faust_app.halted = false
faust_app.scope_trigger = false
local autohalt = ffi.new("bool[1]",false)
local showplot = ffi.new("bool[1]",true)
local showdemo = ffi.new("bool[1]",false)

faust_app.user_loop = function(self)
  ig.SetNextWindowSize(self.igio.DisplaySize)
  ig.SetNextWindowPos(ig.ImVec2(0, 0))
  ig.Begin("__", nil, ig.lib.ImGuiWindowFlags_NoTitleBar + ig.lib.ImGuiWindowFlags_NoResize)
  
  if jit.os ~= "Windows" and self.fw:has_changed() then
    self:restart_dsp()
  end
  
  if ig.Button("Open DSP file") then
    local dialog_dsp_path = ffi.new("char[2048]")
    if self.MfxFaustLib.openDspDialog(dialog_dsp_path) then
      self:restart_dsp(ffi.string(dialog_dsp_path))
    end
  end

  if self.running then
    ig.SeparatorText(ui_builder.faust_ui_tbl[1].label);
    self:add_faust_ui()
  else
    ig.SeparatorText("Error:");
    ig.TextWrapped(self.error_msg)
    ig.GetWindowDrawList().AddRect(ig.GetWindowDrawList(), ig.ImVec2(ig.GetItemRectMin().x-2, ig.GetItemRectMin().y-2), ig.ImVec2(ig.GetItemRectMin().x + ig.GetColumnWidth(), ig.GetItemRectMax().y+2), 0xff666666)
  end
  ig.Separator();
  
  -- ig.SeparatorText("Controller status");
  -- -- Show buttons pressed
  -- self:button("a"); ig.SameLine(); self:button("b"); ig.SameLine(); self:button("x"); ig.SameLine(); self:button("y");
  -- self:button("left"); ig.SameLine(); self:button("right"); ig.SameLine(); self:button("up"); ig.SameLine(); self:button("down")
  -- self:button("lb"); ig.SameLine(); self:button("rb")
  -- self:button("lt"); ig.SameLine(); self:button("rt")
  -- self:button("fn"); ig.SameLine(); self:button("select"); ig.SameLine(); self:button("start")
  -- self:button("left_stick"); ig.SameLine(); self:button("right_stick")
  -- 
  -- -- Show axes
  -- local x_l = ffi.new("int[1]")
  -- x_l[0] = self.axes['L x']
  -- ig.SliderInt("L x", x_l,-32767,32767)
  -- print(self.axes['L x'])
  
  local math = require "math"
  
  if self.running then  
    local available = self.MfxFaustLib.mfx_ringbuffer_read_space(self.rb)
    while (available > 0) do
      if (available >= ffi.sizeof("struct rb_compute_buffers")) then
        local recv = ffi.new("struct rb_compute_buffers[1]")
        local read = self.MfxFaustLib.mfx_ringbuffer_read(self.rb, ffi.cast("void*", recv), ffi.sizeof("struct rb_compute_buffers"))
        local nframes_sizeof = recv[0].nframes * ffi.sizeof("float")
        local scope_sizeof = ffi.sizeof("float") * scope_length[0]
        if self.total_samples_read < scope_length[0] then
          for c=0,recv[0].channels-1 do
            ffi.C.memmove(self.scope_buffer[c], self.scope_buffer[c] + (recv[0].nframes - 1), scope_sizeof - nframes_sizeof)
            ffi.C.memcpy((self.scope_buffer[c] + scope_length[0]) - recv[0].nframes, recv[0].buffers[c], nframes_sizeof)
          end
        end
        -- if (recv[0].buffers[3][0] > 0) and (self.scope_trigger == false) then
        --   self.scope_trigger = true
        --   self.total_samples_read = 0
        --   self.halted = false
        --   self:reset_scope()
        -- end
        if autohalt[0] then
          self.total_samples_read = self.total_samples_read + recv[0].nframes
        end
          
        if self.total_samples_read > scope_length[0] and not self.halted then
          if autohalt[0] then self.total_samples_read = scope_length[0] end
          for c=0,recv[0].channels-1 do
            ffi.C.memcpy(self.scope_buffer[c], (self.scope_buffer[c] + scope_length[0]) - math.min(scope_length[0], self.total_samples_read), math.min(scope_length[0], self.total_samples_read))
          end
          self.halted = true
          self.scope_trigger = false
        end
      end
      available = self.MfxFaustLib.mfx_ringbuffer_read_space(self.rb)
    end
  end
  
  if ig.Checkbox("Auto halt", autohalt) then
    self.total_samples_read = 0
    self.halted = false
    self.scope_trigger = false
    self:reset_scope()
  end

  ig.Checkbox("Show plot", showplot)
  if showplot[0] then
      ig.SliderInt("DSP plot length", scope_length, 2048, 48000)
      if (ig.ImPlot_BeginPlot("DSP plot", ig.ImVec2(ig.GetWindowSize().x - 20, ig.GetWindowSize().y - 100))) then
        ig.ImPlot_SetupAxis(0, "Sample index", ig.lib.ImPlotAxisFlags_AutoFit);
        for c=0,4-1 do
          ig.ImPlot_PlotLine("output " .. c, self.scope_buffer[c] + 0, scope_length[0]);
        end
        ig.ImPlot_EndPlot();
      end
    end
  
  if showdemo[0] then
    ig.ShowDemoWindow()
  end
  
  ig.End()
end

-- Run main loop
faust_app.MfxFaustLib.printVersionAndTarget()
faust_app:run()
faust_app:stop_dsp()
