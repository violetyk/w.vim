let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V        = vital#of(g:w_of_vital)
let s:DateTime = s:V.import('DateTime')
let s:Random   = s:V.import('Random.Xor128')

function! w#settings#default()
  let self = {}

  function! self.note_dir() " {{{
    let dir = g:w_note_dir
    if match(dir, '/$') < 0
      let dir = dir . '/'
    endif
    return dir
  endfunction " }}}

  function! self.note_extension() "{{{
    return '.md'
  endfunction "}}}

  function! self.filename() "{{{
    let d = s:DateTime.now()
    let rand = abs(s:Random.rand())
    return d.format('%Y/%m/%d/%H%M%S')
          \ . rand
          \ . self.note_extension()
  endfunction "}}}

  function! self.parser(filepath) "{{{
    return w#parser#new(a:filepath)
  endfunction "}}}

  function! self.sidebar_controller() "{{{
    return w#sidebar_controller#new()
  endfunction "}}}

  function! self.menu_controller() "{{{
    return w#menu_controller#new()
  endfunction "}}}

  function! self.database_dir() " {{{
    let dir = g:w_database_dir
    if match(dir, '/$') < 0
      let dir = dir . '/'
    endif
    return dir
  endfunction " }}}

  function! self.database_file() " {{{
    return 'w.sqlite'
  endfunction " }}}

  function! self.bufvar_name() "{{{
    return 'wbufvar'
  endfunction "}}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
