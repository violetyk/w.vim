if exists('g:loaded_w_vim')
  finish
endif
let g:loaded_w_vim = 1

let s:save_cpo = &cpo
set cpo&vim


function! s:open() "{{{
  call w#sidebar#open('mysidebar', 'left', 30)
endfunction "}}}

function! s:close() "{{{
  call w#sidebar#close('mysidebar')
endfunction "}}}

function! s:toggle() "{{{
  call w#sidebar#toggle('mysidebar')
endfunction "}}}


command! Wopen call s:open()
command! Wclose call s:close()
command! Wtoggle call s:toggle()


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
