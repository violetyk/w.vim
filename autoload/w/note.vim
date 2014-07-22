let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V    = vital#of(g:w_of_vital)
let s:File = s:V.import('System.File')

function! w#note#create() "{{{
  let filepath = g:w#settings.note_dir() . g:w#settings.filename()
  call s:File.mkdir_nothrow(fnamemodify(filepath, ':p:h'), 'p')
  return filepath
endfunction "}}}

function! w#note#write(filepath, title, new_tags, old_tags) "{{{
  return w#database#save_note(a:filepath, a:title, a:new_tags, a:old_tags)
endfunction "}}}

function! w#note#delete(filepath) "{{{
  return w#database#delete_note(a:filepath) && delete(a:filepath) == 0
  " return w#database#delete_note(a:filepath)
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
