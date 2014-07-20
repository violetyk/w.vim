let s:save_cpo = &cpo
set cpo&vim

let s:sidebar_number = 0

function! w#sidebar#open(name, location, width, controller, ...) "{{{

  let location =  a:location ==# 'left' ? 'topleft' : 'botright'

  if !w#sidebar#exists(a:name)
    let sidebar_buf = s:alloc(a:name, location, a:width, a:controller)
    silent! exec printf('%s vertical %d new', location, a:width)
    silent! exec printf('edit %s', sidebar_buf.bufname)

    " set buffer state
    call s:set_options()

    " allocated sidebar start a own controller
    call sidebar_buf.controller.startup(w#sidebar#get(a:name))

    " callback
    if a:0 == 1 && type(a:1) == type(function('tr'))
      call call(a:1, [sidebar_buf])
    endif
  else
    let sidebar_buf = w#sidebar#get(a:name)
    if !w#sidebar#is_open(a:name)
      " reopen & move to sidebar
      silent! exec printf('%s vertical %d split', location, a:width)
      silent! exec printf('buffer %s', sidebar_buf.bufname)
    else
      " move to opened sidebar
      silent!exec printf('%swincmd w', bufwinnr(sidebar_buf.bufname))
    endif
  endif

  return sidebar_buf
endfunction "}}}

function! w#sidebar#close(name) " {{{
  let window_count = winnr('$')
  if window_count == 1
    close
  else
    " move & close
    let sidebar_buf = w#sidebar#get(a:name)
    let cmd = printf('%d wincmd w', bufwinnr(sidebar_buf.bufname))
    execute cmd
    close
  endif
endfunction " }}}

function! w#sidebar#toggle(name) "{{{
  if w#sidebar#exists(a:name)
    if w#sidebar#is_open(a:name)
      call w#sidebar#close(a:name)
    else
      let sidebar_buf = w#sidebar#get(a:name)
      call w#sidebar#open(a:name, sidebar_buf.location, sidebar_buf.width)
    endif
  endif
endfunction "}}}

function! s:alloc(name, location, width, controller) "{{{
  " script scope
  let s:sidebar_number = s:sidebar_number + 1

  let d = gettabvar(tabpagenr(), a:name, {
        \ 'name'      : a:name,
        \ 'bufname'   : printf('%s_%d', a:name, s:sidebar_number),
        \ 'number'    : s:sidebar_number,
        \ 'location'  : a:location,
        \ 'width'     : a:width,
        \ 'controller': a:controller
        \ })

  call settabvar(tabpagenr(), a:name, d)

  return d
endfunction "}}}

function! w#sidebar#exists(name) "{{{
  let sidebar_buf = gettabvar(tabpagenr(), a:name, {})
  return !empty(sidebar_buf)
endfunction "}}}

function! w#sidebar#get(name) "{{{
  return gettabvar(tabpagenr(), a:name)
endfunction "}}}

function! w#sidebar#is_open(name) "{{{
  if !w#sidebar#exists(a:name)
    return 0
  endif

  let sidebar_buf = w#sidebar#get(a:name)
  return bufwinnr(sidebar_buf.bufname) != -1
endfunction "}}}

function! s:set_options() "{{{
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

  setlocal cursorline
  setlocal nocursorcolumn
  setfiletype wsidebar
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
