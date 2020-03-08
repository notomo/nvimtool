
local module = {}

local function count_pattern(haystack, needle)
    local start = 0
    local next = haystack:find(needle, start)
    local c = 0
    while next ~= nil do
        start = next + 1
        c = c + 1
        next = haystack:find(needle, start)
    end
    return c
end

local function pp(sexpr)
    local result = ""
    local next = sexpr:find("%(", 2)
    local start = 0
    local indent = ''
    while next ~= nil do
        local sub = sexpr:sub(start, next - 1)
        local name_pos = sub:find("%S+:")
        local name = ""
        if name_pos ~= nil then
           name = sub:sub(name_pos)
           sub = sub:sub(0, name_pos - 1)
        end
        local count = count_pattern(sub, "%)")
        if count == 0 then
            indent = indent .. '  '
        else
            indent = indent:sub(0, - count * 2 + 1)
        end
        result = result .. sub .. "\n" .. indent .. name .. "("
        start = next + 1
        next = sexpr:find("%(", start)
    end
    result = result .. sexpr:sub(start)
    return result
end

local FILE_TYPE = "nvimtool-tree"

local function close_windows()
    local ids = vim.api.nvim_tabpage_list_wins(0)
    for _, id in ipairs(ids) do
        local buf = vim.api.nvim_win_get_buf(id)
        local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
        if filetype == FILE_TYPE then
            vim.api.nvim_win_close(id, true)
        end
    end
end

local function open_window(sexpr)
    close_windows()

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", FILE_TYPE)
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
    local config = {
        width=80,
        height=vim.api.nvim_get_option("lines") / 2,
        relative='editor',
        row=3,
        col=vim.api.nvim_get_option("columns") - 4,
        external=false,
        anchor="NE",
        style='minimal',
    }

    vim.api.nvim_open_win(bufnr, false, config)
    local lines = vim.split(pp(sexpr), "\n", false)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

local parser_names = { vim="vimscript" }
local function get_tree()
    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    local name = parser_names[filetype]
    if name == nil then
        name = filetype
    end
    local parser = vim.treesitter.get_parser(0, name)
    return parser:parse()
end

function module.root()
    local tree = get_tree()
    local node = tree:root()
    open_window(node:sexpr())
end

function module.child()
    local tree = get_tree()
    local root = tree:root()
    local row, column = unpack(vim.api.nvim_win_get_cursor(0))
    local count = root:child_count()
    local sexpr = ""
    for i = 0, count - 1 do
        local sr, sc, er, ec = unpack({root:child(i):range()})
        if sr <= row and row <= er and sc <= column and column <= ec then
            sexpr = root:child(i):sexpr()
            break
        end
    end
    if sexpr == "" then
        return
    end

    open_window(sexpr)
end

return module
