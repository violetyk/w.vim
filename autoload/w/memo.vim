let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V    = vital#of(g:w_of_vital)
let s:File = s:V.import('System.File')

function! w#memo#create() "{{{
  let memo_dir = g:w#settings.memo_dir()
  call s:File.mkdir_nothrow(memo_dir, 'p')
  let filepath = memo_dir . g:w#settings.filename()
  return filepath
endfunction "}}}

function! w#memo#write(filepath, parser) "{{{
  let path = fnamemodify(a:filepath, ':s?' . g:w#settings.memo_dir() . '??')
  let title = a:parser.get_title()
  let tags  = a:parser.get_tags()
  return w#database#save_memo(path, title, tags)
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
