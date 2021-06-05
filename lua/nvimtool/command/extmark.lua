local M = {}

function M.echo_by_ns(name, nsid)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".") - 1
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, nsid, {line, 0}, {line, -1}, {details = true})
  for _, mark in ipairs(marks) do
    local text = name .. " = " .. vim.inspect(mark, {newline = " ", indent = ""})
    vim.api.nvim_echo({{text}}, true, {})
  end
end

function M.echo()
  local nss = vim.api.nvim_get_namespaces()
  for name, nsid in pairs(nss) do
    M.echo_by_ns(name, nsid)
  end
end

return M
