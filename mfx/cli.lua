-- mfx/cli.lua

local app = require "pl.app"

local M = {}

function M.parse_args(argv)
  return app.parse_args(argv, {
    path = "Path to Faust DSP file to run"
  })
end

return M
