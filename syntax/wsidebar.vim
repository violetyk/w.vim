if exists("b:current_syntax")
  finish
endif
let s:save_cpo = &cpo
set cpo&vim

syntax region WSidebarHelp start=/^"/ end=/$/ contains=WSidebarHelpKey
syntax match  WSidebarHelpKey '\s\zs.\ze:' contained

" syntax match  WSidebarSectionName '^@\zs.*\ze$' contains=WSidebarSectionMark



syntax match  WSidebarNotePath '<.\+>$' conceal


" :h group-name
highlight link WSidebarHelp Comment
highlight link WSidebarHelpKey Identifier
highlight link WSidebarSectionName PreProc
highlight link WSidebarTag Tag

set conceallevel=3

let b:current_syntax = 'wsidebar'
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
