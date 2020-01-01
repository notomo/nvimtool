-- floatin window debug

local window = {}

local function dump(bufnr, config)
    local lines = {}
    for line in string.gmatch(vim.inspect(config), "[^\r\n]+") do
        table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

function window.open()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local config = {
        width=24,
        height=16,
        relative='editor',
        row=0,
        col=0,
        external=false,
        style='minimal',
    }
    vim.api.nvim_open_win(bufnr, true, config)
    dump(bufnr, vim.api.nvim_win_get_config(id))

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'h', ":<C-u>NvimTool window left<CR>", { noremap=true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'j', ":<C-u>NvimTool window down<CR>", { noremap=true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'k', ":<C-u>NvimTool window up<CR>", { noremap=true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'l', ":<C-u>NvimTool window right<CR>", { noremap=true })
end

function window.left()
    local id = vim.api.nvim_call_function('win_getid', {})
    local config = vim.api.nvim_win_get_config(id)
    local row = config.row[false]
    local col = config.col[false] - 1
    vim.api.nvim_win_set_config(id, {
        relative='editor',
        row=row,
        col=col,
    })
    dump(bufnr, vim.api.nvim_win_get_config(id))
end

function window.down()
    local id = vim.api.nvim_call_function('win_getid', {})
    local config = vim.api.nvim_win_get_config(id)
    local row = config.row[false] + 1
    local col = config.col[false]
    vim.api.nvim_win_set_config(id, {
        relative='editor',
        row=row,
        col=col,
    })
    dump(bufnr, vim.api.nvim_win_get_config(id))
end

function window.up()
    local id = vim.api.nvim_call_function('win_getid', {})
    local config = vim.api.nvim_win_get_config(id)
    local row = config.row[false] - 1
    local col = config.col[false]
    vim.api.nvim_win_set_config(id, {
        relative='editor',
        row=row,
        col=col,
    })
    dump(bufnr, vim.api.nvim_win_get_config(id))
end

function window.right()
    local id = vim.api.nvim_call_function('win_getid', {})
    local config = vim.api.nvim_win_get_config(id)
    local row = config.row[false]
    local col = config.col[false] + 1
    vim.api.nvim_win_set_config(id, {
        relative='editor',
        row=row,
        col=col,
    })
    dump(bufnr, vim.api.nvim_win_get_config(id))
end

local module = {
    open = window.open,
    left = window.left,
    down = window.down,
    up = window.up,
    right = window.right,
}

return module
