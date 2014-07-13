if exists('g:loaded_w_vim')
  finish
endif
let g:loaded_w_vim = 1

let s:save_cpo = &cpo
set cpo&vim

" global variables
let g:w_sidebar_position = get(g:, 'w_sidebar_position', 'left')
let g:w_sidebar_width    = get(g:, 'w_sidebar_width', 30)
let g:w_disable_features = get(g:, 'w_disable_features', ['sample'])
" let g:w_disable_features = []
let g:w_of_vital         = get(g:, 'w_of_vital', 'vital')


call w#bootstrap()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
