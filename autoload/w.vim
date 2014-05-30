let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of(g:w_of_vital)
let s:Message = s:V.import('Vim.Message')

let g:w#version  = 1

function! w#bootstrap() "{{{
  echo 'uho'
  if !w#database#startup()
    return 0
  endif
  echo 'uho'
  echo 'uho'

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
