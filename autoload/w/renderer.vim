let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of(g:w_of_vital)

function! w#renderer#new()
  let self = {}

  function! self.render(buffer) "{{{
    setlocal modifiable
    call setline(line(".")+1, "=== test ===")
    call cursor(line(".")+1, col("."))

    " draw
    let old_o = @o
    let @o = 'hogehoge'
    let @o = @o. 'piyopiyo'
    let @o = @o. 'aaaa'
    silent put o
    let @o = old_o

    " let old_scrolloff=&scrolloff
    " let &scrolloff=0
    " call cursor(topLine, 1)
    normal! zt
    " call cursor(curLine, curCol)
    " let &scrolloff = old_scrolloff

    setlocal nomodifiable
  endfunction "}}}

  return self
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
