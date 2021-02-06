if exists('g:loaded_nvimtool')
    finish
endif
let g:loaded_nvimtool = 1

command! -nargs=+ NvimTool lua require("nvimtool/command").main(<f-args>)

highlight default link NvimToolTreeQueryMatched Todo
