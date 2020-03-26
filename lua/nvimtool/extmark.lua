
local module = {}

function module.echo_by_ns(name, nsid)
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.fn.line('.') - 1
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, nsid, {line , 0}, {line, -1}, {})
    for _, mark in ipairs(marks) do
        local id, row, col = unpack(mark)
        local cmd = string.format('echomsg "%s: mark_id=%d pos=[%d, %d]"', name, id, row, col)
        vim.api.nvim_command(cmd)
    end
end

function module.echo()
    local nss = vim.api.nvim_get_namespaces()
    for name, nsid in pairs(nss) do
        module.echo_by_ns(name, nsid)
    end
end

return module
