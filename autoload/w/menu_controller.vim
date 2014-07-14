let s:save_cpo = &cpo
set cpo&vim

" vital.vim
let s:V      = vital#of(g:w_of_vital)

function! w#menu_controller#new()
  let self = {}
  let self._selected_index = -1
  let self.menu = []

  function! self.show() "{{{
    let _lazyredraw = &lazyredraw
    let _cmdheight  = &cmdheight
    set nolazyredraw
    let &cmdheight = len(self.menu) + 1

    let self._selected_index = 0

    try
      let done = 0
      while !done
        redraw!
        call self.echo_prompt()
        let key = nr2char(getchar())
        let done = self.keypress(key)
      endwhile

    finally
      let &cmdheight  = _cmdheight
      let &lazyredraw = _lazyredraw
      redraw!
    endtry

    let selected = get(self.menu, self._selected_index, {})
    if !empty(selected)
      " invoke menu command
    endif
  endfunction "}}}

  function! self.keypress(key) "{{{
    if a:key == 'j'
      call self._cursor_down()
    elseif a:key == 'k'
      call self._cursor_up()
    elseif a:key == nr2char(27) || a:key == 'q'
      call self._quit()
      return 1
    elseif a:key == "\r" || a:key == "\n"
      return 1
    endif

    return 0
  endfunction "}}}

  function! self._cursor_down() "{{{
    if self._selected_index < len(self.menu) - 1
      let self._selected_index += 1
    else
      let self._selected_index = 0
    endif
  endfunction "}}}

  function! self._cursor_up() "{{{
    if self._selected_index > 0
      let self._selected_index -= 1
    else
      let self._selected_index = len(self.menu) -1
    endif
  endfunction "}}}

  function! self._quit() "{{{
    let self._selected_index = -1
  endfunction "}}}


  function! self.echo_prompt() " {{{
    echo '=== Please select (j/k/enter/esc/q) =========='
    for i in range(0, len(self.menu) - 1)
      if i == self._selected_index
        echo "> " . self.menu[i]
      else
        echo "  " . self.menu[i]
      endif
    endfor
  endfunction " }}}



  return self

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:

finish
