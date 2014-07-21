let s:save_cpo = &cpo
set cpo&vim

" Basic features

let s:feature = {
      \ 'name': 'w',
      \ 'menu': {
      \   'delete_note': {
      \     'text': 'Delete note'
      \   },
      \ },
      \}

function! s:feature.menu.delete_note.callback(context) " {{{

  let choice = confirm("Are you sure you want to delete?\n" . a:context.filepath, "&Yes\n&No", 2)
  if choice == 1 " Yes
    call w#delete_note(a:context.filepath)
  endif
endfunction "}}}

function! w#features#w#load() "{{{
  return [
        \ s:feature,
        \ ]
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
