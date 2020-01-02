
let s:helper = NvimToolTestHelper()
let s:suite = s:helper.suite('window')
let s:assert = s:helper.assert()

function! s:suite.open()
    NvimTool window open

    call s:assert.window_count(2)
endfunction

function! s:suite.move()
    NvimTool window open
    let config = nvim_win_get_config(0)

    NvimTool window down
    call s:assert.window_row(config.row + 1.0)

    NvimTool window up
    call s:assert.window_row(config.row)

    NvimTool window right
    call s:assert.window_col(config.col + 1.0)

    NvimTool window left
    call s:assert.window_col(config.col)

    call s:assert.window_count(2)
endfunction
