let s:save_cpo = &cpo
set cpo&vim

let s:sidebar_number = 0

function! w#sidebar#open(name, location, width) "{{{

  let l:location =  a:location ==# 'left' ? 'topleft' : 'botright'

  if !s:exists(a:name)
    let l:sidebar_buf = s:alloc(a:name, a:location, a:width)
    silent! exec printf('%s vertical %d new', l:location, a:width)
    silent! exec printf('edit %s', l:sidebar_buf.bufname)
  else
    let l:sidebar_buf = s:get(a:name)
    silent! exec printf('%s vertical %d split', l:location, a:width)
    silent! exec printf('buffer %s', l:sidebar_buf.bufname)
  endif

  setlocal winfixwidth
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal buflisted
  setlocal nowrap
  setlocal foldcolumn=0
  setlocal foldmethod=manual
  setlocal nofoldenable
  setlocal nobuflisted
  setlocal nospell
  setlocal nonu
  setlocal nornu

  iabc <buffer>

  setlocal nocursorline
  setlocal nocursorcolumn
  setfiletype w_sidebar

  " let renderer = g:w#settings.renderer()
  " call renderer.render()

  setlocal modifiable
  call setline(line(".")+1, "=== test ===")
  call cursor(line(".")+1, col("."))

  " draw
  let old_o = @o
  let @o = 'hogehoge'
  let @o = @o. 'piyopiyo'
  let @o = @o. 'aaaa'
  silent put o
  let @o = old_o

  " let old_scrolloff=&scrolloff
  " let &scrolloff=0
  " call cursor(topLine, 1)
  normal! zt
  " call cursor(curLine, curCol)
  " let &scrolloff = old_scrolloff

  setlocal nomodifiable


endfunction "}}}

function! w#sidebar#close(name) " {{{
  let l:window_count = winnr('$')
  if l:window_count == 1
    close
  else
    " move & close
    let l:sidebar_buf = s:get(a:name)
    let cmd = printf('%d wincmd w', bufwinnr(l:sidebar_buf.bufname))
    execute cmd
    close
  endif
endfunction " }}}

function! w#sidebar#toggle(name) "{{{
  if s:exists(a:name)
    if s:is_open(a:name)
      call w#sidebar#close(a:name)
    else
      let l:sidebar_buf = s:get(a:name)
      call w#sidebar#open(a:name, l:sidebar_buf.location, l:sidebar_buf.width)
    endif
  endif
endfunction "}}}

function! s:alloc(name, location, width) "{{{
  " script scope
  let s:sidebar_number = s:sidebar_number + 1

  let d = gettabvar(tabpagenr(), a:name, {
        \ 'bufname'  : printf('%s_%d', a:name, s:sidebar_number),
        \ 'number'   : s:sidebar_number,
        \ 'location' : a:location,
        \ 'width'    : a:width
        \ })

  call settabvar(tabpagenr(), a:name, d)

  return d
endfunction "}}}

function! s:exists(name) "{{{
  let l:sidebar_buf = gettabvar(tabpagenr(), a:name, {})
  return !empty(l:sidebar_buf)
endfunction "}}}

function! s:get(name) "{{{
  return gettabvar(tabpagenr(), a:name)
endfunction "}}}

function! s:is_open(name) "{{{
  if !s:exists(a:name)
    return 0
  endif

  let l:sidebar_buf = s:get(a:name)
  return bufwinnr(l:sidebar_buf.bufname) != -1
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
