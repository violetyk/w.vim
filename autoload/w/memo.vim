let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V    = vital#of(g:w_of_vital)
let s:File = s:V.import('System.File')

function! w#memo#create() "{{{
  call g:w#event_manager.notify('memo_before_create')

  let memo_dir = g:w#settings.memo_dir()
  call s:File.mkdir_nothrow(memo_dir, 'p')
  let filepath = memo_dir . g:w#settings.filename()
  call w#memo#open(filepath)

  let context = {}
  let context.filepath = filepath
  call g:w#event_manager.notify('memo_after_create', context)
endfunction "}}}

function! w#memo#open(path, ...) " {{{

  if !bufexists(a:path)
    exec "badd " . a:path
  endif

  let l:option = get(a:000, 1, '')
  let l:line   = get(a:000, 2, 0)

  let buf_no = bufnr(a:path)
  if buf_no != -1
    if l:option == 's'
      exec "sb" . buf_no
    elseif l:option == 'v'
      exec "vert sb" . buf_no
    elseif l:option == 't'
      exec "tabedit"
      exec "b" . buf_no
    else
      exec "b" . buf_no
    endif

    if type(l:line) == type(0) && l:line > 0
      exec l:line
      exec "normal! z\<CR>"
      exec "normal! ^"
    endif

  endif
endfunction "}}}

function! w#memo#write(filepath) "{{{
  let parser = g:w#settings.parser(a:filepath)
  let path = fnamemodify(a:filepath, ':s?' . g:w#settings.memo_dir() . '??')
  let title = parser.get_title()
  let tags  = parser.get_tags()

  if w#database#save_memo(path, title, tags)
    let context = {}
    let context.path  = path
    let context.title = title
    let context.tags  = tags
    call g:w#event_manager.notify('memo_after_write', context)
  endif
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
