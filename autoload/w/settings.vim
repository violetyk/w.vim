let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V        = vital#of(g:w_of_vital)
let s:DateTime = s:V.import('DateTime')
let s:Random   = s:V.import('Random.Xor128')

function! w#settings#default()
  let self = {}

  function! self.memo_dir() " {{{
    return $HOME . '/.vim_w/memo/'
  endfunction " }}}

  function! self.memo_extension() "{{{
    return '.txt'
  endfunction "}}}

  function! self.filename() "{{{
    let d = s:DateTime.now()
    return printf('%s%s_%s%s',
          \ d.format('%Y%m%d%H%M%S'),
          \ abs(s:Random.rand()),
          \ hostname(),
          \ self.memo_extension()
          \ )
  endfunction "}}}

  function! self.parser(filepath) "{{{
    return w#parser#new(a:filepath)
  endfunction "}}}

  function! self.database_dir() " {{{
    return $HOME . '/.vim_w/'
  endfunction " }}}

  function! self.database_file() " {{{
    return 'w.sqlite'
  endfunction " }}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
