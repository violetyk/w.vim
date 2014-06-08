let s:save_cpo = &cpo
set cpo&vim

" vital.vim
let s:V      = vital#of(g:w_of_vital)
let s:String = s:V.import('Data.String')

function! w#controller#new()
  let self = {}
  let self._buffer = {}
  let self._section_name_recent_memos = 'Recent Memos'
  let self._section_name_recent_tags = 'Recent Tags'
  let self._section_name_all_tags = 'All Tags'

  function! self.startup(buffer) "{{{
    " A reference to the sidebar that contains me
    let self._buffer = a:buffer

    " bind mappings
    execute printf('nnoremap <buffer> <silent> <CR> :<C-u>call w#sidebar#get(''%s'').controller.invoke()<CR>', self._buffer.name)

    " render main
    call self.view_main()

  endfunction "}}}

  function! self.invoke() "{{{
    let section_type = self.detect_section_type(line('.'))

    let line = getline('.')
    if section_type == 'memo'
      let path = matchstr(line, self.indent('.*\s<\zs.\+\ze>$'))
      call w#edit_memo(path)
    endif
  endfunction "}}}


  function! self.detect_section_type(line_number) "{{{
    let section_type = ''

    " scan upward
    let n = a:line_number
    let sections = {
          \ self.section(self._section_name_recent_memos) : 'memo',
          \ self.section(self._section_name_recent_tags)  : 'tag',
          \ self.section(self._section_name_all_tags)     : 'tag'
          \ }
    while n > 0
      if index(keys(sections), getline(n)) != -1
        let section_type = sections[getline(n)]
        break
      endif

      let n = n - 1
    endwhile

    return section_type
  endfunction "}}}

  function! self.view_main() "{{{
    let _line = line('.')
    let _col  = col('.')
    let _top_line_of_buffer = line('w0')

    call self.clear_all()

    setlocal modifiable

    " Recent memos
    call self.draw_line(self.section(self._section_name_recent_memos))
    let limit = 20
    let i = 0
    for v in w#database#find_mru_memos(limit)
      let path = g:w#settings.memo_dir() . v.path
      call self.draw_line(self.indent(printf('%s <%s>', s:String.pad_right(v.title, g:w_sidebar_width), path)))
      let i = i + 1
    endfor
    if i == limit
      call self.draw_line('(more...)')
    endif
    call self.draw_line('')

    " Recent tags
    call self.draw_line(self.section(self._section_name_recent_tags))
    for v in w#database#find_mru_tags(5)
      call self.draw_line(self.indent(printf('[%s] %d', v.name, v.memo_count)))
    endfor
    call self.draw_line('')

    " All tags
    call self.draw_line(self.section(self._section_name_all_tags))
    for v in w#database#find_all_tags()
      call self.draw_line(self.indent(printf('[%s] %d', v.name, v.memo_count)))
    endfor


    let _scrolloff = &scrolloff
    let &scrolloff = 0
    call cursor(_top_line_of_buffer, 1)
    normal! zt
    call cursor(_line, _col)
    let &scrolloff = _scrolloff

    setlocal nomodifiable
  endfunction "}}}

  function! self.section(name) "{{{
    return s:String.pad_right('=== ' . a:name . ' ', g:w_sidebar_width, '=')
  endfunction "}}}

  function! self.indent(str, ...) "{{{
    let indent = '  '
    let level = 1
    if a:0 > 0
      let level = a:1
    endif

    let _s = ''
    let i = 1
    while i <= level
      let _s = _s . indent
      let i = i + 1
    endwhile

    return _s . a:str
  endfunction "}}}

  function! self.draw_line(str, ...) "{{{
    call setline(line(".") + 1, a:str)

    " write and new line (default)
    if a:0 == 0 || a:1 == 0
      call cursor(line(".") + 1, col("."))
    endif
  endfunction "}}}

  function! self.target() "{{{
    let cmd = printf('%d wincmd w', bufwinnr(self._buffer.bufname))
    execute cmd
  endfunction "}}}

  function! self.clear_all() "{{{
    call self.target()
    setlocal modifiable
    silent 1,$delete _
    setlocal nomodifiable
  endfunction "}}}

  return self

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker: