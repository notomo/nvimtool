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

local vassert = require("vusted.assert")
local asserts = vassert.asserts

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("window_width"):register_eq(function()
  return vim.api.nvim_win_get_width(0)
end)

asserts.create("window_row"):register_eq(function()
  return vim.api.nvim_win_get_config(0).row[false]
end)

asserts.create("window_col"):register_eq(function()
  return vim.api.nvim_win_get_config(0).col[false]
end)

package.loaded["test.helper"] = M
