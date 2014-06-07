let s:save_cpo = &cpo
set cpo&vim

let s:feature = {
      \ 'name': 'sample',
      \ 'events': {},
      \}

function! s:feature.events.bootstrap(...) "{{{
  echo '[feature:sample] Loaded ' . s:feature.name
endfunction "}}}
function! s:feature.events.sidebar_initialize(...) "{{{
  echo '[feature:sample] Initialize sidebar'
endfunction "}}}
function! s:feature.events.memo_before_create(...) "{{{
  echo '[feature:sample] What do you write?'
endfunction "}}}
function! s:feature.events.memo_after_create(...) "{{{
  echo "[feature:sample] Please don't forget to save!"
endfunction "}}}
function! s:feature.events.memo_before_write(...) "{{{
  echo "[feature:sample] Before Write! " . a:1.filepath
endfunction "}}}
function! s:feature.events.memo_after_write(...) "{{{
  echo "[feature:sample] After Write! " . a:1.filepath
endfunction "}}}

function! w#features#sample#load() "{{{
  return [
        \ s:feature,
        \ ]
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
