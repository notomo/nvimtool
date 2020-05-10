-- floating window debug

local module = {}

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
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if not filetype == WINDOW_FILE_TYPE then
    return
  end

  vim.api.nvim_win_set_config(id, {
    relative=relative,
    row=row,
    col=col,
  })
  dump(bufnr, vim.api.nvim_win_get_config(id))
  vim.api.nvim_buf_set_option(bufnr, "modified", false)
end

function module.open()
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
  local id = vim.api.nvim_open_win(bufnr, true, config)

  dump(bufnr, vim.api.nvim_win_get_config(id))

  vim.api.nvim_buf_set_option(bufnr, "filetype", WINDOW_FILE_TYPE)
  vim.api.nvim_buf_set_option(bufnr, "modified", false)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
  vim.api.nvim_buf_set_name(bufnr, "nvimtool_window://" .. bufnr)

  local write_autocmd = string.format("autocmd BufWriteCmd <buffer=%s> NvimTool window save %s", bufnr, bufnr)
  vim.api.nvim_command(write_autocmd)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'H', ":<C-u>NvimTool window left<CR>", { noremap=true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'J', ":<C-u>NvimTool window down<CR>", { noremap=true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', ":<C-u>NvimTool window up<CR>", { noremap=true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'L', ":<C-u>NvimTool window right<CR>", { noremap=true })
end

function module.save(bufnr)
  local lines = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "")
  local config = vim.fn.luaeval(lines)
  local id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_config(id, {
    anchor=config.anchor,
    width=config.width,
    height=config.height,
    relative=config.relative,
    row=config.row,
    col=config.col,
    external=config.external,
    focusable=config.focusable,
    style=config.style,
  })
  vim.api.nvim_buf_set_option(bufnr, "modified", false)
end

function module.left()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false]
  local col = config.col[false] - 1
  update(id, row, col, config.relative)
end

function module.down()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false] + 1
  local col = config.col[false]
  update(id, row, col, config.relative)
end

function module.up()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false] - 1
  local col = config.col[false]
  update(id, row, col, config.relative)
end

function module.right()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false]
  local col = config.col[false] + 1
  update(id, row, col, config.relative)
end

return module
