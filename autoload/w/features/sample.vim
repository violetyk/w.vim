let s:save_cpo = &cpo
set cpo&vim

let s:feature = {
      \ 'name': 'sample',
      \ 'events': {},
      \}

function! s:feature.events.bootstrap(...) "{{{
  echo 'Loaded ' . s:feature.name
endfunction "}}}
function! s:feature.events.memo_before_create(...) "{{{
  echo 'What do you write?'
endfunction "}}}
function! s:feature.events.memo_after_create(...) "{{{
  echo "Please don't forget to save!"
endfunction "}}}
function! s:feature.events.memo_after_write(...) "{{{
  echo "Write! " . a:1.filepath
endfunction "}}}

function! w#features#sample#load() "{{{
  return [
        \ s:feature,
        \ ]
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
