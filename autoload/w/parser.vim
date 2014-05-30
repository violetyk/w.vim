let s:save_cpo = &cpo
set cpo&vim

function! w#parser#new(filepath)
  let self = {}
  let self._filepath = a:filepath

  " The first line is title.
  function! self.get_title() "{{{
    let title = get(readline(self._filepath, '', 1), 0, '')
    if !strlen(title)
      let title = 'No title'
    endif
    return title
  endfunction "}}}

  " The second line is tags.
  " Format:
  "  [tagname1][tagname2][tagname3]...
  function! self.tags() "{{{
    let tags = []
    let line = get(readline(self._filepath, '', 2), 1, '')
    if !strlen(line)
      " let tags = ...
    endif
    return tags
  endfunction "}}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
