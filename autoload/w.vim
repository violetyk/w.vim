let s:save_cpo = &cpo
set cpo&vim

function! w#bootstrap() "{{{

  " default settings
  let g:w#settings = w#settings#default()

  " event manager
  let g:w#event_manager = w#event_manager#new()

  " enable plugin feature
  call w#feature#load_all(g:w_disable_features, g:w#event_manager)

  " initialize database
  if !w#database#startup()
    return 0
  endif

  " bootstrap event
  call g:w#event_manager.notify('bootstrap')

  " register auto commands
  augroup w_vim_memo
    autocmd!
    autocmd BufWritePost *
          \ let dir = finddir(g:w#settings.memo_dir(), escape(expand("%:p:h"), ' \') . ';') |
          \ if isdirectory(dir) | call w#memo#write(expand("%:p")) | endif
  augroup END

  " register commands
  command! WSidebarOpen call w#sidebar#open('wsidebar',
        \ g:w_sidebar_position,
        \ g:w_sidebar_width,
        \ s:func_ref('render', s:__sid())
        \ )
  command! WSidebarClose call w#sidebar#close('wsidebar')
  command! WSidebarToggle call w#sidebar#toggle('wsidebar')
  command! WMemoNew  call w#memo#create()

  return 1
endfunction "}}}

function! s:render(...) "{{{
  call g:w#event_manager.notify('sidebar_initialize')
  let sidebar_buf = a:1
  let renderer = g:w#settings.renderer()
  call renderer.render(sidebar_buf)
endfunction "}}}

function! s:__sid() " {{{
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze___sid$')
endfunction "}}}

function! s:func_ref(function_name, sid) " {{{
    return function(printf('<SNR>%d_%s', a:sid, a:function_name))
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
