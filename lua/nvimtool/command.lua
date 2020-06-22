local M = {}

M.main = function(...)
  local args = {...}
  if #args < 2 then
    return vim.api.nvim_err_write("not enough arguments: " .. vim.inspect(args) .. "\n")
  end

  local file_name = args[1]
  local cmd_name = args[2]
  local cmd_args = table.concat({unpack(args, 3)}, ",")
  local name = ("nvimtool/command/%s"):format(file_name)
  local ok, cmd = pcall(require, name)
  if not ok then
    return vim.api.nvim_err_write("not found command: args=" .. vim.inspect(args) .. "\n")
  end
  return cmd[cmd_name](cmd_args)
end

return M
