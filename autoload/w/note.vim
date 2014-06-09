let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V    = vital#of(g:w_of_vital)
let s:File = s:V.import('System.File')

function! w#note#create() "{{{
  let note_dir = g:w#settings.note_dir()
  call s:File.mkdir_nothrow(note_dir, 'p')
  let filepath = note_dir . g:w#settings.filename()
  return filepath
endfunction "}}}

function! w#note#write(filepath, parser) "{{{
  let path     = fnamemodify(a:filepath, ':s?' . g:w#settings.note_dir() . '??')
  let title    = a:parser.get_title()
  let new_tags = a:parser.get_tags()

  let bufvar = w#buffer#getvar(a:filepath, g:w#settings.bufvar_name())
  let old_tags = get(bufvar, 'tags', {})

  return w#database#save_note(path, title, new_tags, old_tags)
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
