
local module = {}

function module.echo()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.fn.line('.') - 1
    local texts = vim.api.nvim_buf_get_virtual_text(bufnr, line)
    for _, text in ipairs(texts) do
        local cmd = string.format('echomsg "%s"', vim.fn.escape(text[1], '"\\'))
        vim.api.nvim_command(cmd)
    end
end

return module
