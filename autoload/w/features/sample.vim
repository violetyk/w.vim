let s:save_cpo = &cpo
set cpo&vim

let s:feature = {
      \ 'name': 'sample',
      \ 'event': {},
      \ 'menu': {
      \   'set_note_data': {
      \     'text': 'Set data of note'
      \   },
      \   'get_note_data': {
      \     'text': 'Get data of note'
      \   },
      \ },
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

function! s:feature.menu.set_note_data.callback(context) " {{{
  let data = input('Set data: ')
  if w#database#set_note_context(a:context.filepath, 'sample', data)
    echo "\nSuccess!"
  else
    echo "\nFailure!"
  end
endfunction "}}}

function! s:feature.menu.get_note_data.callback(context) " {{{
  echo w#database#get_note_context(a:context.filepath, 'sample')
endfunction "}}}


function! w#features#sample#load() "{{{
  return [
        \ s:feature,
        \ ]
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
