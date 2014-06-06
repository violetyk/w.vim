let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V      = vital#of(g:w_of_vital)
let s:String = s:V.import('Data.String')

function! w#renderer#new()
  let self = {}
  let self._buffer = {}

  function! self.view_main(buffer) "{{{
    let self._buffer = a:buffer

    let _line = line(".")
    let _col  = col(".")
    let _top_line_of_buffer = line("w0")

    call self.clear_all()

    setlocal modifiable

    " Recent memos
    call self.draw_line(self.section('Rcent Memos'))
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
    call self.draw_line(self.section('Recent Tags'))
    for v in w#database#find_mru_tags(5)
      call self.draw_line(self.indent(printf('[%s] %d', v.name, v.memo_count)))
    endfor
    call self.draw_line('')

    " All tags
    call self.draw_line(self.section('All Tags'))
    for v in w#database#find_all_tags()
      call self.draw_line(self.indent(printf('[%s] %d', v.name, v.memo_count)))
    endfor


    let _scrolloff = &scrolloff
    let &scrolloff = 0
    call cursor(_top_line_of_buffer, 1)
    normal! zt
    call cursor(_line, _col)
    let &scrolloff = _scrolloff

    " let old_o = @o
    " let @o = 'hogehoge'
    " let @o = @o. 'piyopiyo'
    " let @o = @o. 'aaaa'
    " silent put o
    " let @o = old_o


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

  " write and new line (default)
  function! self.draw_line(str, ...) "{{{
    call setline(line(".") + 1, a:str)
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
