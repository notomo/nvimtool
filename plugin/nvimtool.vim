if exists('g:loaded_nvimtool')
    finish
endif
let g:loaded_nvimtool = 1

if get(g:, 'nvimtool_debug', v:false)
    command! -nargs=+ NvimTool lua require("nvimtool/cleanup")("nvimtool"); require("nvimtool/command").main(<f-args>)
else
    command! -nargs=+ NvimTool lua require("nvimtool/command").main(<f-args>)
endif

highlight default link NvimToolTreeQueryMatched Todo
