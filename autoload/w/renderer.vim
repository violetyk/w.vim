let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of(g:w_of_vital)
let s:Message = s:V.import('Vim.Message')


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
