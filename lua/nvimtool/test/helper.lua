local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each() end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  print(" ")
end

function helper.search(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local msg = ("%s not found"):format(pattern)
    assert(false, msg)
  end
  return result
end

function helper.replace_line(new_line)
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

return helper
