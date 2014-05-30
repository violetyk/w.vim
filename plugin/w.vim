if exists('g:loaded_w_vim')
  finish
endif
let g:loaded_w_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" global variables
" let g:w_disable_features = get(g:, 'w_disable_features', ['sample'])
let g:w_disable_features = []
let g:w_of_vital         = get(g:, 'w_of_vital', 'vital')

" default settings
let g:w#settings = w#settings#default()

" event manager
let g:w#event_manager = w#events#new()

" enable plugin feature
call w#feature#load_all(g:w_disable_features, g:w#event_manager)

" bootstrap
if w#bootstrap()
  " register auto commands
  augroup w_vim_memo
    autocmd!
    autocmd BufWritePost *.txt 
          \ let dir = finddir(g:w#settings.memo_dir(), escape(expand("%:p:h"), ' \') . ';') |
          \ if isdirectory(dir) | call w#memo#write(expand("%:p")) | endif
  augroup END


  command! Wopen call w#sidebar#open('mysidebar', 'left', 30)
  command! Wclose call w#sidebar#close('mysidebar')
  command! Wtoggle call w#sidebar#toggle('mysidebar')
  command! Wnew  call w#memo#create()
endif



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
