local M = {}

M.root = vim.fn.getcwd()

M.command = function(cmd)
  vim.api.nvim_command(cmd)
end

M.before_each = function()
  M.command("filetype on")
  M.command("syntax enable")
end

M.after_each = function()
  M.command("tabedit")
  M.command("tabonly!")
  M.command("silent! %bwipeout!")
  M.command("filetype off")
  M.command("syntax off")
  print(" ")
end

M.search = function(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local msg = string.format("%s not found", pattern)
    assert(false, msg)
  end
  return result
end

M.replace_line = function(new_line)
  vim.fn.setline(".", new_line)
end

local assert = require("luassert")
local AM = {}

AM.window_count = function(expected)
  local actual = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
  local msg = string.format("window count should be %s, but actual: %s", expected, actual)
  assert.equals(expected, actual, msg)
end

AM.window_width = function(expected)
  local actual = vim.api.nvim_win_get_width(0)
  local msg = string.format("window width should be %s, but actual: %s", expected, actual)
  assert.equals(expected, actual, msg)
end

AM.window_row = function(expected)
  local actual = vim.api.nvim_win_get_config(0).row[false]
  local msg = string.format("window row should be %s, but actual: %s", expected, actual)
  assert.equals(expected, actual, msg)
end

AM.window_col = function(expected)
  local actual = vim.api.nvim_win_get_config(0).col[false]
  local msg = string.format("window col should be %s, but actual: %s", expected, actual)
  assert.equals(expected, actual, msg)
end

M.assert = AM

return M
