let s:save_cpo = &cpo
set cpo&vim

let s:sample_a = {
      \ 'name': 'sample_a',
      \ 'callbacks': {
      \   'feature': {},
      \   'memo': {},
      \ }
      \}

let s:sample_b = {'name': 'sample_b'}

function! s:sample_a.callbacks.feature.after_load(...) "{{{
  echo 'loaded sample feature.'
endfunction "}}}
function! s:sample_a.callbacks.memo.before_create(...) "{{{
  echo 'What do you write?'
endfunction "}}}
function! s:sample_a.callbacks.memo.after_create(...) "{{{
  echo a:000
endfunction "}}}

function! w#features#sample#load() "{{{
  return [
        \ s:sample_a,
        \ s:sample_b
        \ ]
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
