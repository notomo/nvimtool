
local module = {}
local ns = vim.api.nvim_create_namespace("nvimtool-tree-query")

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

local TREE_FILE_TYPE = "nvimtool-tree"
local QUERY_FILE_TYPE = "nvimtool-tree-query"

local function close_windows()
  local ids = vim.api.nvim_tabpage_list_wins(0)
  for _, id in ipairs(ids) do
    local buf = vim.api.nvim_win_get_buf(id)
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    if filetype == TREE_FILE_TYPE then
      vim.api.nvim_win_close(id, true)
    end
  end
end

local function open_window(sexpr)
  close_windows()

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "filetype", TREE_FILE_TYPE)
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
local function get_lang(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local name = parser_names[filetype]
  if name == nil then
    return filetype
  end
  return name
end

local function get_tree(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, get_lang(bufnr))
  return parser:parse()
end

function module.root()
  local tree = get_tree(0)
  local node = tree:root()
  open_window(node:sexpr())
end

function module.child()
  local tree = get_tree(0)
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

function module.query()
  vim.api.nvim_command("only")

  local tree = get_tree(0)
  local node = tree:root()
  local lines = vim.split(pp(node:sexpr()), "\n", false)

  local target_bufnr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(target_bufnr)

  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("wincmd w")

  local tree_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. tree_bufnr)
  vim.api.nvim_buf_set_option(tree_bufnr, "filetype", TREE_FILE_TYPE)
  vim.api.nvim_buf_set_option(tree_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_lines(tree_bufnr, 0, -1, false, lines)

  vim.api.nvim_command("split")
  vim.api.nvim_command("wincmd w")

  local query_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_command("buffer " .. query_bufnr)
  local default_content = '((comment) @var (match? @var "test"))'
  vim.api.nvim_buf_set_lines(query_bufnr, 0, -1, false, {default_content})
  vim.api.nvim_buf_set_option(query_bufnr, "modified", false)
  vim.api.nvim_buf_set_option(query_bufnr, "filetype", QUERY_FILE_TYPE)
  vim.api.nvim_buf_set_option(query_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(query_bufnr, "buftype", "acwrite")
  vim.api.nvim_buf_set_name(query_bufnr, "nvimtool_query://" .. buf_name)

  local write_autocmd = string.format("autocmd BufWriteCmd <buffer=%s> NvimTool tree save_query %s %s", query_bufnr, target_bufnr, query_bufnr)
  vim.api.nvim_command(write_autocmd)

  local wipeout_autocmd = string.format("autocmd BufWipeout <buffer=%s> NvimTool tree reset_query %s", query_bufnr, target_bufnr)
  vim.api.nvim_command(wipeout_autocmd)
end

function module.save_query(target_bufnr, query_bufnr)
  vim.api.nvim_buf_set_option(query_bufnr, "modified", false)
  local query = table.concat(vim.api.nvim_buf_get_lines(query_bufnr, 0, -1, false), "")
  tsquery = vim.treesitter.parse_query(get_lang(target_bufnr), query)

  vim.api.nvim_buf_clear_namespace(target_bufnr, ns, 0, -1)
  for _, node in tsquery:iter_captures(get_tree(target_bufnr):root(), target_bufnr, 0, -1) do
    local sr, sc, er, ec = unpack({node:range()})
    for row = sr, er  do
      local start_col = 0
      local end_col = -1
      if row == sr then
        start_col = sc
      end
      if row == er then
        end_col = ec
      end
      vim.api.nvim_buf_add_highlight(target_bufnr, ns, "NvimToolTreeQueryMatched", row, start_col, end_col)
    end
  end
end

function module.reset_query(target_bufnr)
  vim.api.nvim_buf_clear_namespace(target_bufnr, ns, 0, -1)
end

return module
