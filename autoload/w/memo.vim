let s:save_cpo = &cpo
set cpo&vim

let s:callbacks = w#callbacks#new()

function! w#memo#create() "{{{

  call w#mkdir('/.vim_w/memo/')

  call s:callbacks.notify('before_create')

  " create file...

  call s:callbacks.notify('after_create')

endfunction "}}}

function! w#memo#add_callback(name, listener) "{{{
  return s:callbacks.add(a:name, a:listener)
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
