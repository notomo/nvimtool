local M = {}

local function dump(bufnr, config)
  local lines = {}
  for line in string.gmatch(vim.inspect(config), "[^\r\n]+") do
    table.insert(lines, line)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local WINDOW_FILE_TYPE = "nvimtool-window"

local function update(id, row, col, relative)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  if not filetype == WINDOW_FILE_TYPE then
    return
  end

  vim.api.nvim_win_set_config(id, { relative = relative, row = row, col = col })
  dump(bufnr, vim.api.nvim_win_get_config(id))
  vim.bo[bufnr].modified = false
end

function M.open()
  local bufnr = vim.api.nvim_create_buf(false, true)

  local config = {
    width = 24,
    height = 16,
    relative = "editor",
    row = 0,
    col = 0,
    external = false,
    style = "minimal",
    border = "double",
  }
  local id = vim.api.nvim_open_win(bufnr, true, config)

  dump(bufnr, vim.api.nvim_win_get_config(id))

  vim.bo[bufnr].filetype = WINDOW_FILE_TYPE
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buftype = "acwrite"
  vim.api.nvim_buf_set_name(bufnr, "nvimtool_window://" .. bufnr)

  local write_autocmd = string.format(
    "autocmd BufWriteCmd <buffer=%s> lua require('nvimtool').window.save(%s)",
    bufnr,
    bufnr
  )
  vim.cmd(write_autocmd)

  vim.api.nvim_buf_set_keymap(bufnr, "n", "H", "<Cmd>lua require('nvimtool').window.left()<CR>", {
    noremap = true,
  })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "J", "<Cmd>lua require('nvimtool').window.down()<CR>", {
    noremap = true,
  })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<Cmd>lua require('nvimtool').window.up()<CR>", {
    noremap = true,
  })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "L", "<Cmd>lua require('nvimtool').window.right()<CR>", {
    noremap = true,
  })
end

function M.save(bufnr)
  local lines = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "")
  local config = vim.fn.luaeval(lines)
  local id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_config(id, {
    anchor = config.anchor,
    width = config.width,
    height = config.height,
    relative = config.relative,
    row = config.row,
    col = config.col,
    external = config.external,
    focusable = config.focusable,
    style = config.style,
    border = config.border or "none",
    zindex = config.zindex or 50,
  })
  vim.bo[bufnr].modified = false
end

function M.left()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false]
  local col = config.col[false] - 1
  update(id, row, col, config.relative)
end

function M.down()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false] + 1
  local col = config.col[false]
  update(id, row, col, config.relative)
end

function M.up()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false] - 1
  local col = config.col[false]
  update(id, row, col, config.relative)
end

function M.right()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false]
  local col = config.col[false] + 1
  update(id, row, col, config.relative)
end

return M
