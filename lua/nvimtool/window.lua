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

local function update(id, row, col)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if not filetype == WINDOW_FILE_TYPE then
    return
  end

  vim.api.nvim_win_set_config(id, {
    relative='editor',
    row=row,
    col=col,
  })
  dump(bufnr, vim.api.nvim_win_get_config(id))
end

function module.open()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "filetype", WINDOW_FILE_TYPE)

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

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'h', ":<C-u>NvimTool window left<CR>", { noremap=true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'j', ":<C-u>NvimTool window down<CR>", { noremap=true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'k', ":<C-u>NvimTool window up<CR>", { noremap=true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'l', ":<C-u>NvimTool window right<CR>", { noremap=true })
end

function module.left()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false]
  local col = config.col[false] - 1
  update(id, row, col)
end

function module.down()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false] + 1
  local col = config.col[false]
  update(id, row, col)
end

function module.up()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false] - 1
  local col = config.col[false]
  update(id, row, col)
end

function module.right()
  local id = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(id)
  local row = config.row[false]
  local col = config.col[false] + 1
  update(id, row, col)
end

return module
