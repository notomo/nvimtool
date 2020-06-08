
local module = {}

function module.echo()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line('.') - 1
  local chunks = vim.api.nvim_buf_get_virtual_text(bufnr, line)
  for _, chunk in ipairs(chunks) do
    local text = chunk[1]
    local cmd = string.format('echomsg "%s"', vim.fn.escape(text, '"\\'))
    vim.api.nvim_command(cmd)
  end
end

function module.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  local nss = vim.api.nvim_get_namespaces()
  for _, nsid in pairs(nss) do
    vim.api.nvim_buf_clear_namespace(bufnr, nsid, 0, -1)
  end
end

function module.clear_one()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line('.') - 1
  local nss = vim.api.nvim_get_namespaces()
  for _, nsid in pairs(nss) do
    vim.api.nvim_buf_clear_namespace(bufnr, nsid, line, line + 1)
  end
end

return module
