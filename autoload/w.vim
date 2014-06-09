let s:save_cpo = &cpo
set cpo&vim

let s:sidebar_name = 'wsidebar'

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
  augroup w_vim_note
    autocmd!
    autocmd BufWritePost *
          \ if w#in_note_dir(expand("%:p"))| call w#write_note(expand("%:p")) | endif
  augroup END

  " register commands
  command! WSidebarOpen call w#open_sidebar()
  " command! WSidebarClose call w#sidebar#close('wsidebar')
  " command! WSidebarToggle call w#sidebar#toggle('wsidebar')
  command! WNoteNew  call w#create_note()

  return 1
endfunction "}}}

function! w#open_sidebar() "{{{
  let sidebar = w#sidebar#open(
        \ s:sidebar_name,
        \ g:w_sidebar_position,
        \ g:w_sidebar_width,
        \ g:w#settings.controller()
        \ )

  " initialize event
  call g:w#event_manager.notify('sidebar_initialize', sidebar)
endfunction "}}}

function! w#in_note_dir(filepath) "{{{
  return match(a:filepath, '^' . g:w#settings.note_dir()) != -1
endfunction "}}}

function! w#create_note() "{{{
  call g:w#event_manager.notify('note_before_create')

  let filepath = w#note#create()
  call w#buffer#add_new(filepath)

  let context = {}
  let context.filepath = filepath
  call g:w#event_manager.notify('note_after_create', context)
endfunction "}}}

function! w#write_note(filepath) "{{{
  " get parser
  let parser = g:w#settings.parser(a:filepath)

  let context = {}
  let context.fileath = a:filepath
  let context.parser  = parser
  
  call g:w#event_manager.notify('note_before_write', context)

  " write
  if w#note#write(a:filepath, parser)
    let context.fileath = a:filepath
    let context.parser  = parser
    call g:w#event_manager.notify('note_after_write', context)

    " reload sidebar
    let sidebar = w#sidebar#get(s:sidebar_name)
    if !empty(sidebar)
      " TODO: to abstract
      call sidebar.controller.reload_view()
    endif
  endif
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
