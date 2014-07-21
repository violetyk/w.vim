let s:save_cpo = &cpo
set cpo&vim

let s:feature = {
      \ 'name': 'sample',
      \ 'event': {},
      \}

function! s:feature.event.bootstrap(context) "{{{
  echo '[feature:sample] Loaded ' . s:feature.name
endfunction "}}}
function! s:feature.event.sidebar_initialize(context) "{{{
  echo '[feature:sample] Initialize sidebar'
endfunction "}}}
function! s:feature.event.note_before_create(context) "{{{
  echo '[feature:sample] What do you write?'
endfunction "}}}
function! s:feature.event.note_after_create(context) "{{{
  echo "[feature:sample] Please don't forget to save!"
endfunction "}}}
function! s:feature.event.note_after_read(context) "{{{
  echo "[feature:sample] After Read! " . a:context.filepath
endfunction "}}}
function! s:feature.event.note_before_write(context) "{{{
  echo "[feature:sample] Before Write! " . a:context.filepath
endfunction "}}}
function! s:feature.event.note_after_write(context) "{{{
  echo "[feature:sample] After Write! " . a:context.filepath
endfunction "}}}
function! s:feature.event.note_before_delete(context) "{{{
  echo "[feature:sample] Before delete! " . a:context.filepath
endfunction "}}}
function! s:feature.event.note_after_delete(context) "{{{
  echo "[feature:sample] After delete! " . a:context.filepath
endfunction "}}}

function! w#features#sample#load() "{{{
  return [
        \ s:feature,
        \ ]
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
