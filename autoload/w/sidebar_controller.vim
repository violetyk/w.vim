let s:save_cpo = &cpo
set cpo&vim

" vital.vim
let s:V      = vital#of(g:w_of_vital)
let s:String = s:V.import('Data.String')

function! w#sidebar_controller#new()
  let self = {}
  let self._buffer = {}
  let self._section_name_recent_notes = 'Recent Notes'
  let self._section_name_recent_tags = 'Recent Tags'
  let self._section_name_all_tags = 'All Tags'
  let self._section_name_notes = 'Notes'

  function! self.startup(buffer) "{{{
    " A reference to the sidebar that contains me
    let self._buffer = a:buffer

    " bind mappings
    execute printf('nnoremap <buffer> <silent> <CR> :<C-u>call w#sidebar#get(''%s'').controller.invoke()<CR>', self._buffer.name)
    execute printf('nnoremap <buffer> <silent> <nowait> ~ :<C-u>call w#sidebar#get(''%s'').controller.main()<CR>', self._buffer.name)
    execute printf('nnoremap <buffer> <silent> <nowait> m :<C-u>call w#sidebar#get(''%s'').controller.show_menu()<CR>', self._buffer.name)
    execute printf('nnoremap <buffer> <silent> <nowait> s :<C-u>call w#sidebar#get(''%s'').controller.grep("")<CR>', self._buffer.name)
    execute 'nnoremap <buffer> <silent> <nowait> c :<C-u>call w#create_note()<CR>'
    execute 'nnoremap <buffer> <silent> <nowait> q :<C-u>call w#close_sidebar()<CR>'

    " render main
    call self.main()

  endfunction "}}}

  function! self.reload_view() "{{{
    call self.main()
  endfunction "}}}

  function! self.invoke() "{{{
    let node = self.current_node()
    if empty(node)
      return
    endif

    if node.type == 'note'

      if node.line ==  '(more...)'
        call self.find({})
      elseif strlen(node.filepath) > 0
        call w#buffer#edit(node.filepath, 3)
      endif

    elseif node.type == 'tag'

      call self.find({'tag': node.tag})

    endif
  endfunction "}}}

  function! self.current_node() "{{{
    let node = {}
    let section_type = self.detect_section_type(line('.'))
    let line = getline('.')

    if section_type == 'note'
      let node['type']     = 'note'
      let node['filepath'] = matchstr(line, self.indent('.*\s<\zs.\+\ze>$'))
      let node['line']     = line
    elseif section_type == 'tag'
      let node['type'] = 'tag'
      let node['tag']  = s:String.trim(matchstr(line, self.indent('\[\zs.\+\ze\]\s\d\+$')))
      let node['line'] = line
    endif

    return node
  endfunction "}}}

  function! self.detect_section_type(line_number) "{{{
    let section_type = ''

    " scan upward
    let n = a:line_number
    let sections = {
          \ self.section(self._section_name_recent_notes) : 'note',
          \ self.section(self._section_name_recent_tags)  : 'tag',
          \ self.section(self._section_name_all_tags)     : 'tag',
          \ self.section(self._section_name_notes)        : 'note'
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

  function! self.grep(word) "{{{

    let word = a:word
    if word == ''
      let word = input('Grep word: ')
    endif
    if word == ''
      return
    endif

    let _line = line('.')
    let _col  = col('.')
    let _top_line_of_buffer = line('w0')

    call self.clear_all()

    setlocal modifiable

    call self.draw_navigation()
    call self.draw_line(self.section(self._section_name_notes))


    let is_qflist_open = 0
    let i = 1
    while i <= winnr('$')
      let bufnr = winbufnr(i)

      if bufnr == -1
        break
      endif

      if getbufvar(bufnr, '&buftype') == 'quickfix'
        let is_qflist_open = 1
        break
      endif

      let i += 1
    endwhile

    let current_qflist = getqflist()

    try
      call setqflist([], ' ')
      execute printf('silent vimgrep /%s/jg %s', word, g:w#settings.note_dir() . '*')
      execute self.winnr() . 'wincmd w'

      let note_dir = g:w#settings.note_dir()

      for d in getqflist()
        let f = bufname(d.bufnr)
        let path = fnamemodify(f, ':s?' . note_dir . '??')
        let notes = w#database#find_notes({'path': path, 'limit': 1})
        if has_key(notes[0], 'title')
          call self.draw_line(self.indent(
                \ printf('%s <%s>',
                \ s:String.pad_right(notes[0].title, g:w_sidebar_width),
                \ note_dir . notes[0].path
                \ )))
        endif
      endfor

    finally
      call setqflist(current_qflist, 'r')
      if is_qflist_open == 0
        execute 'cclose'
      endif
    endtry

    let _scrolloff = &scrolloff
    let &scrolloff = 0
    call cursor(_top_line_of_buffer, 1)
    normal! zt
    call cursor(_line, _col)
    let &scrolloff = _scrolloff

    setlocal nomodifiable
  endfunction "}}}

  function! self.find(context) "{{{
    let _line = line('.')
    let _col  = col('.')
    let _top_line_of_buffer = line('w0')

    call self.clear_all()

    setlocal modifiable

    call self.draw_navigation()
    call self.draw_line(self.section(self._section_name_notes))

    " find notes
    for v in w#database#find_notes(a:context)
      if has_key(v, 'path')
        let path = g:w#settings.note_dir() . v.path
        call self.draw_line(self.indent(printf('%s <%s>', s:String.pad_right(v.title, g:w_sidebar_width), path)))
      endif
    endfor

    let _scrolloff = &scrolloff
    let &scrolloff = 0
    call cursor(_top_line_of_buffer, 1)
    normal! zt
    call cursor(_line, _col)
    let &scrolloff = _scrolloff

    setlocal nomodifiable
  endfunction "}}}

  function! self.main() "{{{
    let _line = line('.')
    let _col  = col('.')
    let _top_line_of_buffer = line('w0')

    call self.clear_all()

    setlocal modifiable

    call self.draw_navigation()

    " Recent notes
    call self.draw_line(self.section(self._section_name_recent_notes))
    let limit = 20
    let i = 0
    for v in w#database#find_notes({'limit': limit})
      let path = g:w#settings.note_dir() . v.path
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
      call self.draw_line(self.indent(printf('[%s] %d', v.name, v.note_count)))
    endfor
    call self.draw_line('')

    " All tags
    call self.draw_line(self.section(self._section_name_all_tags))
    for v in w#database#find_all_tags()
      call self.draw_line(self.indent(printf('[%s] %d', v.name, v.note_count)))
    endfor


    let _scrolloff = &scrolloff
    let &scrolloff = 0
    call cursor(_top_line_of_buffer, 1)
    normal! zt
    call cursor(_line, _col)
    let &scrolloff = _scrolloff

    setlocal nomodifiable
  endfunction "}}}

  function! self.show_menu() "{{{
    let menu_controller = g:w#settings.menu_controller()
    call menu_controller.show()
    unlet menu_controller
  endfunction "}}}

  function! self.draw_navigation() "{{{
    call setline(line("."), '" ~: Home  c: Create')
    call self.draw_line('')
    call setline(line("."), '" m: Menu  s: Search')
    call self.draw_line('')
  endfunction "}}}

  function! self.section(name) "{{{
    return '* ' . a:name
    " return s:String.pad_right('--- ' . a:name . ' ', g:w_sidebar_width, '-')
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

    function! self.winnr() "{{{
      return bufwinnr(bufnr(self._buffer.bufname))
    endfunction "}}}
  return self

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
