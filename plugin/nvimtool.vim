if exists('g:loaded_nvimtool')
    finish
endif
let g:loaded_nvimtool = 1

command! -nargs=+ NvimTool call nvimtool#run(<f-args>)
