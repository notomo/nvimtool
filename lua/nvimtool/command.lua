local M = {}

local slice = function(tbl, first, last)
  local result = {}
  for i = first or 1, last or #tbl, 1 do
    result[#result + 1] = tbl[i]
  end
  return result
end

M.main = function(...)
  local args = {...}
  if #args < 2 then
    return vim.api.nvim_err_write("not enough arguments: " .. vim.inspect(args) .. "\n")
  end

  local file_name = args[1]
  local cmd_name = args[2]
  local cmd_args = table.concat(slice(args, 3), ",")
  local name = ("nvimtool/command/%s"):format(file_name)
  for _, path in ipairs(vim.split(package.path, ";")) do
    local p = path:gsub("?", name)
    if vim.fn.filereadable(p) == 1 then
      local cmd = dofile(p)
      return cmd[cmd_name](cmd_args)
    end
  end

  return vim.api.nvim_err_write("not found command: args=" .. vim.inspect(args) .. "\n")
end

return M
