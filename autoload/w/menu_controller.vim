let s:save_cpo = &cpo
set cpo&vim

" vital.vim
let s:V      = vital#of(g:w_of_vital)

function! w#menu_controller#new()
  let self = {}

  return self

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
