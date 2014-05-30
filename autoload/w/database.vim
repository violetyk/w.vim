let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of(g:w_of_vital)
let s:Message = s:V.import('Vim.Message')
let s:DB      = s:V.import('Database.SQLite')


" どこでバージョン定義するかな
" let g:w#version  = 1

function! w#database#startup() "{{{
  if !s:DB.is_available()
    call s:Message.error('[w.vim] sqlite3 is not executable.')
    return 0
  endif


  return 1
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
