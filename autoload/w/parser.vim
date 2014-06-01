let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V      = vital#of(g:w_of_vital)
let s:String = s:V.import('Data.String')
let s:List   = s:V.import('Data.List')

function! w#parser#new(filepath)
  let self = {}
  let self._filepath = a:filepath

  " The first line is title.
  function! self.get_title() "{{{
    let title = get(readfile(self._filepath, '', 1), 0, '')
    if !strlen(title)
      let title = 'No title'
    endif
    return title
  endfunction "}}}

  " The second line is tags.
  " Format:
  "  [tagname1][tagname2][tagname3]...
  function! self.get_tags() "{{{
    let tags = []
    let line = get(readfile(self._filepath, '', 2), 1, '')
    if strlen(line)
      for v in split(line, ']\zs')
        let t = s:String.trim(matchstr(v, '\[\zs.\+\ze\]'))
        if strlen(t)
          call add(tags, t)
        endif
      endfor
    endif
    return s:List.uniq(tags)
  endfunction "}}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
