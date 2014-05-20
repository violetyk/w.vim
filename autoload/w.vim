let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of('vital')
let s:Message = s:V.import('Vim.Message')
let s:DB      = s:V.import('Database.SQLite')

let g:w#version  = 1

function! w#bootstrap() "{{{

  if !s:DB.is_available()
    call s:Message.error('[w.vim] sqlite3 is not executable.')
    return 0
  endif

  " let r =  s:DB.query('vim_w', 'select name from sqlite_master')
  " let r =  s:DB.query('vim_w', 'insert into meta values(3, "hogepiyo");')
  " let r =  s:DB.query('vim_w', 'select data from meta;')
  " for v in r
    " echo v.data
  " endfor

  call g:w#event_manager.notify('bootstrap')

  return 1
endfunction "}}}




let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
