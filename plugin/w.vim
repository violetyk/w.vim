if exists('g:loaded_w_vim')
  finish
endif
let g:loaded_w_vim = 1

let s:save_cpo = &cpo
set cpo&vim



let g:w#settings = w#settings#default()

command! Wopen call w#sidebar#open('mysidebar', 'left', 30)
command! Wclose call w#sidebar#close('mysidebar')
command! Wtoggle call w#sidebar#toggle('mysidebar')

command! Wnew  call w#memo#create()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
