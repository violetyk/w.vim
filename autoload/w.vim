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
    autocmd BufRead *
          \ if w#in_note_dir(expand("%:p"))| call w#read_note(expand("%:p")) | endif
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
  " parse
  let parser   = g:w#settings.parser(a:filepath)
  let title    = parser.get_title()
  let new_tags = parser.get_tags()

  let context          = {}
  let context.filepath = a:filepath
  let context.title    = title
  let context.tagss    = new_tags

  call g:w#event_manager.notify('note_before_write', context)

  let bufvar   = w#buffer#getvar(a:filepath, g:w#settings.bufvar_name())
  let old_tags = get(bufvar, 'tags', {})

  " write
  if w#note#write(a:filepath, title, new_tags, old_tags)

    " update current bufvar
    call w#buffer#setvar(a:filepath, g:w#settings.bufvar_name(), {
          \ 'title' : title,
          \ 'tags'  : new_tags,
          \ })

    " reload sidebar
    let sidebar = w#sidebar#get(s:sidebar_name)
    if !empty(sidebar)
      " TODO: to abstract
      call sidebar.controller.reload_view()
    endif

    call g:w#event_manager.notify('note_after_write', context)
  endif
endfunction "}}}

function! w#read_note(filepath) "{{{
  let parser = g:w#settings.parser(a:filepath)
  let title  = parser.get_title()
  let tags   = parser.get_tags()

  call w#buffer#setvar(a:filepath, g:w#settings.bufvar_name(), {
        \ 'title' : title,
        \ 'tags'  : tags,
        \ })

  let context          = {}
  let context.filepath = a:filepath
  let context.title    = title
  let context.tags     = tags

  call g:w#event_manager.notify('note_after_read', context)
endfunction "}}}

function! w#debug() "{{{
  let bufvar = w#buffer#getvar(expand("%:p"), g:w#settings.bufvar_name())
  echo bufvar
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
