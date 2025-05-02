-- mfx/input/handler.lua

local sdl = require "sdl2_ffi"
local M = {}

local function handle_input(app, name, state, value)
  if value ~= nil then
    print(name .. " " .. value)
    app.axes[name] = value
  elseif app.buttons_states[name] == nil then
    return
  else
    app.buttons_states[name] = state
    print(name .. " " .. app.buttons_states[name])
  end
end

local function handle_event(app, event)
  local type = event.type

  if type == sdl.SDL_CONTROLLERAXISMOTION then
    local axis = event.caxis.axis
    local value = event.caxis.value
    if axis == 0 then handle_input(app, "L x", nil, value) end
    if axis == 1 then handle_input(app, "L y", nil, value) end
    if axis == 2 then handle_input(app, "R x", nil, value) end
    if axis == 3 then handle_input(app, "R y", nil, value) end
    if axis == 4 then handle_input(app, "lt", value == 32767 and 1 or 0) end
    if axis == 5 then handle_input(app, "rt", value == 32767 and 1 or 0) end

  elseif type == sdl.SDL_CONTROLLERBUTTONDOWN or type == sdl.SDL_CONTROLLERBUTTONUP then
    local btn = event.cbutton.button
    local state = event.cbutton.state
    local button_map = {
      [13] = "left", [14] = "right", [11] = "up", [12] = "down",
      [1] = "b", [0] = "a", [2] = "x", [3] = "y",
      [5] = "fn", [4] = "select", [6] = "start",
      [7] = "left_stick", [8] = "right_stick",
      [9] = "lb", [10] = "rb"
    }
    local name = button_map[btn]
    if name then handle_input(app, name, state) end
  end
end

function M.bind(app)
  app.buttons_states = {
    a = 0, b = 0, x = 0, y = 0,
    left = 0, right = 0, up = 0, down = 0,
    lb = 0, rb = 0,
    lt = 0, rt = 0,
    fn = 0, select = 0, start = 0,
    left_stick = 0, right_stick = 0
  }
  app.axes = {
    ["L x"] = 0, ["L y"] = 0, ["R x"] = 0, ["R y"] = 0
  }

  app.process_key_triggers = function(self, event)
    if event.type == sdl.KEYDOWN and event.key.keysym.mod == 4096 and event.key.keysym.sym < 127 then
      local key = string.upper(string.char(event.key.keysym.sym))
      if self.key_triggers[key] ~= nil then self.key_triggers[key] = true end
    end
    if event.type == sdl.KEYUP and event.key.keysym.mod == 4096 and event.key.keysym.sym < 127 then
      local key = string.upper(string.char(event.key.keysym.sym))
      if self.key_triggers[key] ~= nil then self.key_triggers[key] = false end
    end
  end

  app.user_event = function(self)
    local ig = require "imgui.sdl"
    local event = require("ffi").new("SDL_Event")
    while sdl.pollEvent(event) ~= 0 do
      handle_event(self, event)
      ig.lib.ImGui_ImplSDL2_ProcessEvent(event)
      if event.type == sdl.QUIT then done = true end
      if event.type == sdl.KEYDOWN and event.key.keysym.sym == sdl.SDLK_ESCAPE then done = true end
      self:process_key_triggers(event)
    end
  end
end

return M
