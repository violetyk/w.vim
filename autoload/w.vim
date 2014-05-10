let s:save_cpo = &cpo
set cpo&vim

function! w#mkdir(path) "{{{
  silent! return call mkdir(paeth, 'p')
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
