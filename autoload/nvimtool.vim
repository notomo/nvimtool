
let s:path = expand('<sfile>:h:h') . '/lua/nvimtool'

function! nvimtool#run(file_name, ...) abort
    if len(a:000) != 1
        echohl ErrorMsg
        echomsg printf('arguments must be file_name and method_name, but actual: file_name=%s, method_name=%s', a:file_name, string(a:000))
        echohl None | return
    endif

    " TODO: if not debug mode, use require('nvimtool/{a:file_name}')
    let method_name = a:000[0]
    let cmd = printf("lua dofile('%s/%s.lua').%s()", s:path, a:file_name, method_name)
    execute cmd
endfunction
