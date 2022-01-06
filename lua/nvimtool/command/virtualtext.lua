local M = {}

function M.echo()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".") - 1
  local nss = vim.api.nvim_get_namespaces()
  for _, ns in pairs(nss) do
    local ok, results = pcall(vim.api.nvim_buf_get_extmarks, bufnr, ns, { line, 0 }, { line, -1 }, {
      details = true,
    })
    if not ok then
      goto continue
    end

    for _, result in ipairs(results) do
      local details = result[4]
      for _, chunk in ipairs(details.virt_text or {}) do
        local text = chunk[1]
        vim.api.nvim_echo({ { text } }, true, {})
      end
    end

    ::continue::
  end
end

function M.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  local nss = vim.api.nvim_get_namespaces()
  for _, nsid in pairs(nss) do
    vim.api.nvim_buf_clear_namespace(bufnr, nsid, 0, -1)
  end
end

function M.clear_one()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".") - 1
  local nss = vim.api.nvim_get_namespaces()
  for _, nsid in pairs(nss) do
    vim.api.nvim_buf_clear_namespace(bufnr, nsid, line, line + 1)
  end
end

return M
