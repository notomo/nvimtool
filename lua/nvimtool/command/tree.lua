local M = {}
local ns = vim.api.nvim_create_namespace("nvimtool-tree-query")
local tree_ns = vim.api.nvim_create_namespace("nvimtool-tree-query-tree")
local target_cursor_ns = vim.api.nvim_create_namespace("nvimtool-tree-query-target")
local tree_cursor_ns = vim.api.nvim_create_namespace("nvimtool-tree-query-tree-cursor")

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
  local indent = ""
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
      indent = indent .. "  "
    else
      indent = indent:sub(0, -count * 2 + 1)
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
    local filetype = vim.bo[buf].filetype
    if filetype == TREE_FILE_TYPE then
      vim.api.nvim_win_close(id, true)
    end
  end
end

local function open_window(sexpr)
  close_windows()

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].filetype = TREE_FILE_TYPE
  vim.bo[bufnr].bufhidden = "wipe"
  local config = {
    width = 80,
    height = vim.o.lines / 2,
    relative = "editor",
    row = 3,
    col = vim.o.columns - 4,
    external = false,
    anchor = "NE",
    style = "minimal",
  }

  vim.api.nvim_open_win(bufnr, false, config)
  local lines = vim.split(pp(sexpr), "\n", false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

local parser_names = { scheme = "query" }
local function get_lang(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local name = parser_names[filetype]
  if name == nil then
    return filetype
  end
  return name
end

local function get_tree(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, get_lang(bufnr))
  local trees, _ = parser:parse()
  return trees[1]
end

function M.root()
  local tree = get_tree(0)
  local node = tree:root()
  open_window(node:sexpr())
end

local child = function(root, row, column)
  local count = root:child_count()
  for i = 0, count - 1 do
    local sr, sc, er, ec = unpack({ root:child(i):range() })
    if sr <= row and row <= er and sc <= column and column <= ec then
      return root:child(i)
    end
  end
end

function M.child()
  local tree = get_tree(0)
  local root = tree:root()
  local row, column = unpack(vim.api.nvim_win_get_cursor(0))
  local c = child(root, row, column)
  if not c then
    return
  end

  local sexpr = c:sexpr()
  if sexpr == "" then
    return
  end

  open_window(sexpr)
end

local function all_nodes(root, nodes)
  for node in root:iter_children() do
    if node:named() then
      table.insert(nodes, node)
      all_nodes(node, nodes)
    end
  end
  return nodes
end

local tree_lines = function(target_bufnr)
  local tree = get_tree(target_bufnr)
  local node = tree:root()
  M._root = node
  local all = all_nodes(node, { node })
  local ranges = {}
  for _, n in ipairs(all) do
    table.insert(ranges, { n:range() })
  end
  return vim.split(pp(node:sexpr()), "\n", false), ranges
end

function M.query()
  vim.cmd("only")

  local target_bufnr = vim.api.nvim_get_current_buf()

  vim.cmd("vsplit")
  vim.cmd("wincmd w")

  local tree_bufnr = vim.api.nvim_create_buf(false, true)
  vim.cmd("buffer " .. tree_bufnr)
  vim.bo[tree_bufnr].filetype = TREE_FILE_TYPE
  vim.bo[tree_bufnr].bufhidden = "wipe"
  vim.wo.list = false
  M.update_tree(target_bufnr, tree_bufnr)

  vim.cmd("split")
  vim.cmd("wincmd w")

  local query_bufnr = vim.api.nvim_create_buf(false, true)
  vim.cmd("buffer " .. query_bufnr)
  local default_content = [[((comment) @var (match? @var "test"))]]
  vim.api.nvim_buf_set_lines(query_bufnr, 0, -1, false, { default_content })
  vim.bo[query_bufnr].modified = false
  vim.bo[query_bufnr].filetype = QUERY_FILE_TYPE
  vim.bo[query_bufnr].bufhidden = "wipe"
  vim.bo[query_bufnr].buftype = "acwrite"
  vim.api.nvim_buf_set_name(query_bufnr, "nvimtool_query://" .. vim.api.nvim_buf_get_name(target_bufnr))

  vim.cmd([[augroup nvimtool_tree]])
  vim.cmd(
    ("autocmd BufWriteCmd <buffer=%s> lua require('nvimtool').tree.save_query(%s, %s)"):format(
      query_bufnr,
      target_bufnr,
      query_bufnr
    )
  )
  vim.cmd(
    ("autocmd BufWritePost <buffer=%s> lua require('nvimtool').tree.save_query(%s, %s)"):format(
      target_bufnr,
      target_bufnr,
      query_bufnr
    )
  )
  vim.cmd(
    ("autocmd BufWipeout <buffer=%s> lua require('nvimtool').tree.reset_query(%s)"):format(query_bufnr, target_bufnr)
  )
  vim.cmd(
    ("autocmd CursorMoved <buffer=%s> lua require('nvimtool').tree.highlight_target(%s, %s)"):format(
      tree_bufnr,
      target_bufnr,
      tree_bufnr
    )
  )
  vim.cmd(
    ("autocmd WinEnter <buffer=%s> lua require('nvimtool').tree.clear_highlight_target(%s)"):format(
      target_bufnr,
      target_bufnr
    )
  )
  vim.cmd(
    ("autocmd CursorMoved <buffer=%s> lua require('nvimtool').tree.highlight_tree(%s, %s)"):format(
      target_bufnr,
      target_bufnr,
      tree_bufnr
    )
  )
  vim.cmd(
    ("autocmd WinEnter <buffer=%s> lua require('nvimtool').tree.clear_highlight_tree(%s)"):format(
      tree_bufnr,
      tree_bufnr
    )
  )
  vim.cmd([[augroup END]])

  vim.api.nvim_buf_attach(target_bufnr, false, {
    on_lines = function()
      if not (vim.api.nvim_buf_is_valid(target_bufnr) and vim.api.nvim_buf_is_valid(tree_bufnr)) then
        return true
      end
      vim.schedule(function()
        require("nvimtool").tree.update_tree(target_bufnr, tree_bufnr)
      end)
    end,
  })
end

function M.highlight_target(target_bufnr, tree_bufnr)
  if not (vim.api.nvim_buf_is_valid(target_bufnr) and vim.api.nvim_buf_is_valid(tree_bufnr)) then
    vim.cmd([[autocmd! nvimtool_tree WinEnter]])
    return nil
  end
  local window_id = vim.fn.bufwinid(tree_bufnr)
  local row = vim.api.nvim_win_get_cursor(window_id)[1]
  local marks = vim.api.nvim_buf_get_extmarks(tree_bufnr, tree_ns, row, row, { details = true })
  if #marks == 0 then
    return
  end
  M.clear_highlight_target(target_bufnr)
  local text = marks[1][4].virt_text[1][1]
  local sr, sc, er, ec = text:match([=[%[(%d+), (%d+)%] %- %[(%d+), (%d+)%]]=])
  vim.api.nvim_buf_set_extmark(target_bufnr, target_cursor_ns, tonumber(sr), tonumber(sc), {
    end_row = tonumber(er),
    end_col = tonumber(ec),
    hl_group = "Visual",
  })
  local target_window_id = vim.fn.bufwinid(target_bufnr)
  vim.api.nvim_win_set_cursor(target_window_id, { tonumber(sr) + 1, tonumber(sc) })
end

function M.clear_highlight_target(target_bufnr)
  vim.api.nvim_buf_clear_namespace(target_bufnr, target_cursor_ns, 0, -1)
end

function M.clear_highlight_tree(tree_bufnr)
  vim.api.nvim_buf_clear_namespace(tree_bufnr, tree_cursor_ns, 0, -1)
end

function M.highlight_tree(target_bufnr, tree_bufnr)
  if not vim.api.nvim_buf_is_valid(tree_bufnr) then
    return
  end

  local clear = function()
    vim.api.nvim_buf_clear_namespace(tree_bufnr, tree_cursor_ns, 0, -1)
  end

  local window_id = vim.fn.bufwinid(target_bufnr)
  local row, column = unpack(vim.api.nvim_win_get_cursor(window_id))
  local marks = M._row_marks[row - 1]
  if not marks then
    return clear()
  end

  local c = M._root:descendant_for_range(row - 1, column, row - 1, column + 1)
  if not c then
    return clear()
  end
  local sr, sc, er, ec = c:range()
  local id
  for _, m in ipairs(marks) do
    if m.row == sr and m.column == sc and m.end_row == er and m.end_column == ec then
      id = m.id
      break
    end
  end
  if not id then
    return clear()
  end

  local mark = vim.api.nvim_buf_get_extmark_by_id(tree_bufnr, tree_ns, id, {})
  clear()
  vim.api.nvim_buf_set_extmark(tree_bufnr, tree_cursor_ns, mark[1] - 1, 0, {
    end_row = mark[1],
    hl_eol = true,
    hl_group = "Visual",
  })

  local tree_window_id = vim.fn.bufwinid(tree_bufnr)
  vim.api.nvim_win_set_cursor(tree_window_id, { mark[1], 0 })
end

function M.update_tree(target_bufnr, tree_bufnr)
  if not vim.api.nvim_buf_is_valid(tree_bufnr) then
    return
  end

  local lines, ranges = tree_lines(target_bufnr)
  vim.bo[tree_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(tree_bufnr, 0, -1, false, lines)
  vim.bo[tree_bufnr].modifiable = false

  local row_marks = {}
  vim.api.nvim_buf_clear_namespace(tree_bufnr, tree_ns, 0, -1)
  for i, range in ipairs(ranges) do
    local str = ("[%d, %d] - [%d, %d]"):format(unpack(range))
    local id = vim.api.nvim_buf_set_extmark(tree_bufnr, tree_ns, i - 1, 0, {
      virt_text = { { str, "Comment" } },
    })
    local row = range[1]
    local marks = row_marks[row] or {}
    table.insert(marks, { id = id, row = range[1], column = range[2], end_row = range[3], end_column = range[4] })
    row_marks[row] = marks
  end
  M._row_marks = row_marks
end

function M.save_query(target_bufnr, query_bufnr)
  target_bufnr = tonumber(target_bufnr)
  query_bufnr = tonumber(query_bufnr)

  if not vim.api.nvim_buf_is_valid(query_bufnr) then
    return
  end

  vim.bo[query_bufnr].modified = false
  local query = table.concat(vim.api.nvim_buf_get_lines(query_bufnr, 0, -1, false), "")
  local tsquery = vim.treesitter.parse_query(get_lang(target_bufnr), query)

  vim.api.nvim_buf_clear_namespace(target_bufnr, ns, 0, -1)
  for _, node in tsquery:iter_captures(get_tree(target_bufnr):root(), target_bufnr, 0, -1) do
    local sr, sc, er, ec = unpack({ node:range() })
    for row = sr, er do
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

function M.reset_query(target_bufnr)
  vim.api.nvim_buf_clear_namespace(target_bufnr, ns, 0, -1)
end

vim.cmd("highlight default link NvimToolTreeQueryMatched Todo")

return M
