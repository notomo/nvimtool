if exists('g:loaded_nvimtool')
    finish
endif
let g:loaded_nvimtool = 1

if get(g:, 'nvimtool_debug', v:false)
    let s:path = expand('<sfile>:h:h') .. '/lua/'
    execute printf('command! -nargs=+ NvimTool lua require("nvimtool/cleanup")("%s"); require "nvimtool/command".main(<f-args>)', s:path)
else
    command! -nargs=+ NvimTool lua require 'nvimtool/command'.main(<f-args>)
endif

highlight default link NvimToolTreeQueryMatched Todo
