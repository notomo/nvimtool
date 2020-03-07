
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
        local count = count_pattern(sub, "%)")
        if count == 0 then
            indent = indent .. '  '
        else
            indent = indent:sub(0, - count * 2 + 1)
        end
        result = result .. sub .. "\n" .. indent .. "("
        start = next + 1
        next = sexpr:find("%(", start)
    end
    result = result .. sexpr:sub(start)
    return result
end

local function split(str, sep)
  if sep == nil then
      return {}
  end

  local t = {}
  local i = 1
  for s in string.gmatch(str, "([^" .. sep .. "]+)") do
    t[i] = s
    i = i + 1
  end

  return t
end

function module.root()
    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    local parser = vim.treesitter.get_parser(0, filetype)
    local tree = parser:parse()
    local node = tree:root()

    local bufnr = vim.api.nvim_create_buf(false, true)
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

    local lines = split(pp(node:sexpr()), "\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

return module
