local modulelib = require("nvimtool.lib.module")

local M = {}

function M.__index(_, k)
  return modulelib.find("nvimtool.command." .. k)
end

return setmetatable({}, M)
