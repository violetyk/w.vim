let s:save_cpo = &cpo
set cpo&vim

let s:sample_a = {
      \ 'name': 'sample_a',
      \ 'callbacks': {
      \   'memo': {}
      \ }
      \}

let s:sample_b = {'name': 'sample_b'}

function! s:sample_a.callbacks.memo.before_create(...) "{{{
  echo 'What dou you write?'
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
