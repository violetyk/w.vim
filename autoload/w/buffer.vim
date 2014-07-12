let s:save_cpo = &cpo
set cpo&vim

function! w#buffer#add_new(path, ...) "{{{
  let bufvar_dict = get(a:000, 1, {})
  call s:open(a:path, 'n', 0, bufvar_dict)
endfunction "}}}

function! w#buffer#edit(path) "{{{
  if strlen(a:path) && filereadable(a:path)
    execute 'wincmd p'
    call s:open(a:path, 'n', 3)
  endif
endfunction "}}}

function! w#buffer#setvar(expr, name, value) "{{{
  if strlen(bufname(a:expr))
    call setbufvar(bufname(a:expr), a:name, a:value)
  endif
endfunction "}}}

function! w#buffer#getvar(expr, name) "{{{
  if strlen(bufname(a:expr))
    let bufvar = getbufvar(bufname(a:expr), a:name)
    if !empty(bufvar)
      return bufvar
    endif
  endif
  return {}
endfunction "}}}

function! s:open(path, method, line) " {{{

  if !bufexists(a:path)
    exec "badd " . a:path
  endif

  let buf_no = bufnr(a:path)
  if buf_no != -1
    if a:method == 's'      " horizontal plit
      exec "sb" . buf_no
    elseif a:method == 'v'  " vertical split
      exec "vert sb" . buf_no
    elseif a:method == 't'  " tab
      exec "tabedit"
      exec "b" . buf_no
    else                    " current
      exec "b" . buf_no
    endif

    if type(a:line) == type(0) && a:line > 0
      exec a:line
      exec "normal! z\<CR>"
      exec "normal! ^"
    endif
  endif
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
