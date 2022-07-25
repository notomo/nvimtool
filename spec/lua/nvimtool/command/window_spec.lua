local helper = require("nvimtool.lib.testlib.helper")
local nvimtool = helper.require("nvimtool")

describe("window command", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("opens new window", function()
    nvimtool.window.open()

    assert.window_count(2)
  end)

  it("can move window", function()
    nvimtool.window.open()

    local config = vim.api.nvim_win_get_config(0)

    nvimtool.window.down()
    assert.window_row(config.row[false] + 1.0)

    nvimtool.window.up()
    assert.window_row(config.row[false])

    nvimtool.window.right()
    assert.window_col(config.col[false] + 1.0)

    nvimtool.window.left()
    assert.window_col(config.col[false])

    assert.window_count(2)
  end)

  it("can save window config", function()
    nvimtool.window.open()

    local width = 40
    helper.search("width")
    helper.replace_line("width = " .. width .. ",")
    vim.cmd.write()

    assert.window_width(width)
  end)
end)
