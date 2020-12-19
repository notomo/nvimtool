local helper = require("test.helper")
local command = helper.command

describe("window command", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("opens new window", function()
    command("NvimTool window open")

    assert.window_count(2)
  end)

  it("can move window", function()
    command("NvimTool window open")

    local config = vim.api.nvim_win_get_config(0)

    command("NvimTool window down")
    assert.window_row(config.row[false] + 1.0)

    command("NvimTool window up")
    assert.window_row(config.row[false])

    command("NvimTool window right")
    assert.window_col(config.col[false] + 1.0)

    command("NvimTool window left")
    assert.window_col(config.col[false])

    assert.window_count(2)
  end)

  it("can save window config", function()
    command("NvimTool window open")

    local width = 40
    helper.search("width")
    helper.replace_line("width = " .. width .. ",")
    command("write")

    assert.window_width(width)
  end)

end)
