-- mfx/ui/builder.lua

local ffi = require "ffi"
local inspect = require "inspect"
local lib = require "mfx.lib"

local M = {}

M.faust_ui = ffi.new("CLuaUI[1]")
M.faust_ui_tbl = {}


local function to_str(ptr)
  return ffi.string(ptr)
end

local function insert(type_name, data)
  t = { type = type_name }
  for k,v in pairs(data) do t[k] = v end
  table.insert(M.faust_ui_tbl, t)
end

M.faust_ui[0].openTabBox = function(label)
  print("openTabBox", to_str(label))
  insert("openTabBox", { label = to_str(label) })
end

M.faust_ui[0].openHorizontalBox = function(label)
  print("openHorizontalBox", to_str(label))
  insert("openHorizontalBox", { label = to_str(label) })
end

M.faust_ui[0].openVerticalBox = function(label)
  print("openVerticalBox", to_str(label))
  insert("openVerticalBox", { label = to_str(label) })
end

M.faust_ui[0].closeBox = function()
  print("closeBox")
  insert("closeBox", {})
end

M.faust_ui[0].addButton = function(label, zone)
  print("addButton", to_str(label), zone[0])
  insert("addButton", { label = to_str(label), pointer = zone })
end

M.faust_ui[0].addCheckButton = function(label, zone)
  print("addCheckButton", to_str(label), zone[0])
  insert("addCheckButton", { label = to_str(label), pointer = zone })
end

M.faust_ui[0].addHorizontalSlider = function(label, zone, init, min, max, step)
  print("addHorizontalSlider", to_str(label), zone[0], init, min, max, step)
  insert("addHorizontalSlider", { label = to_str(label), pointer = zone, init = init, min = min, max = max, step = step })
end

M.faust_ui[0].addVerticalSlider = function(label, zone, init, min, max, step)
  print("addVerticalSlider", to_str(label), zone[0], init, min, max, step)
  insert("addVerticalSlider", { label = to_str(label), pointer = zone, init = init, min = min, max = max, step = step })
end

M.faust_ui[0].addNumEntry = function(label, zone, init, min, max, step)
  print("addNumEntry", to_str(label), zone[0], init, min, max, step)
  insert("addNumEntry", { label = to_str(label), pointer = zone, init = init, min = min, max = max, step = step })
end

M.faust_ui[0].addHorizontalBargraph = function(label, zone, min, max)
  print("addHorizontalBargraph", to_str(label), zone[0], min, max)
  insert("addHorizontalBargraph", { label = to_str(label), pointer = zone, min = min, max = max })
end

M.faust_ui[0].addVerticalBargraph = function(label, zone, min, max)
  print("addVerticalBargraph", to_str(label), zone[0], min, max)
  insert("addVerticalBargraph", { label = to_str(label), pointer = zone, min = min, max = max })
end

M.faust_ui[0].addSoundfile = function(label, soundpath)
  print("addSoundfile", to_str(label), to_str(soundpath))
  insert("addSoundfile", { label = to_str(label), path = to_str(soundpath) })
end

M.faust_ui[0].declare = function(zone, key, val)
  print("declare", to_str(key), to_str(val))
  insert("declare", { key = to_str(key), value = to_str(val) })
end

return M
