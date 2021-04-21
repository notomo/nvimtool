local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local M = require("vusted.helper")

M.root = M.find_plugin_root(plugin_name)

function M.before_each()
  vim.cmd("filetype on")
  vim.cmd("syntax enable")
end

function M.after_each()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent! %bwipeout!")
  vim.cmd("filetype off")
  vim.cmd("syntax off")
  M.cleanup_loaded_modules(plugin_name)
  print(" ")
end

function M.search(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local msg = string.format("%s not found", pattern)
    assert(false, msg)
  end
  return result
end

function M.replace_line(new_line)
  vim.fn.setline(".", new_line)
end

local asserts = require("vusted.assert").asserts

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

return M
