local M = {}

M.root = vim.fn.getcwd()

function M.require(name)
  return setmetatable({}, {
    __index = function(_, k)
      return require(name)[k]
    end,
  })
end

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
  require("nvimtool.lib.module").cleanup()
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
