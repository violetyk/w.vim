if exists("b:current_syntax")
  finish
endif
let s:save_cpo = &cpo
set cpo&vim

syntax region WSidebarHelp start=/^"/ end=/$/ contains=WSidebarHelpKey
syntax match  WSidebarHelpKey '\s\zs.\ze:' contained

syntax match  WSidebarSectionName '^\*\s.*$'

syntax match  WSidebarNotePath '<.\+>$' conceal
syntax match  WSidebarTag '\(\s\+\)\zs.*\ze\(\s\d\+$\)'
syntax match  WSidebarMore  '^(more\.\.\.)$'


" :h group-name
highlight link WSidebarHelp Comment
highlight link WSidebarHelpKey Identifier
highlight link WSidebarSectionName PreProc
highlight link WSidebarTag Tag
highlight link WSidebarMore Tag

set conceallevel=3

let b:current_syntax = 'wsidebar'
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
