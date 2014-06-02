let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of(g:w_of_vital)
let s:Message = s:V.import('Vim.Message')
let s:File    = s:V.import('System.File')
let s:DB      = s:V.import('Database.SQLite')

let s:version = 1

function! w#database#startup() "{{{
  if !s:DB.is_available()
    call s:Message.error('[w.vim] sqlite3 is not executable.')
    return 0
  endif

  let database_dir = g:w#settings.database_dir()
  call s:File.mkdir_nothrow(database_dir, 'p')

  if w#database#get_version() == 0
    try
      let sql = w#database#loadfile('autoload/w/schema.sql')
      call w#database#query(sql)
      call w#database#query('PRAGMA user_version = ?;', [s:version])
    catch
      call w#database#query('ROLLBACK;')
      return 0
    endtry
  endif

  return 1
endfunction "}}}

function! w#database#query(q, ...) "{{{
  return s:DB.query(
    \ g:w#settings.database_dir() . g:w#settings.database_file(),
    \ a:q,
    \ get(a:000, 0, [])
    \ )
endfunction "}}}

function! w#database#get_version() "{{{
  return get(w#database#query('PRAGMA user_version;')[0], 'user_version', 0)
endfunction "}}}

function! w#database#loadfile(path) "{{{
  let content = ''
  let file = get(split(globpath(&runtimepath, a:path), '\n'), '')

  if filereadable(file)
    let content = join(readfile(file), "\n")
  endif

  return content
endfunction "}}}

function! w#database#archive(path, title, tags) "{{{
  let sql = "BEGIN;\n"
  let params = []

  " UPSERT memo
  let sql .= "INSERT OR IGNORE INTO memos(path, title, modified) VALUES(?, ?, DATETIME('now','localtime'));\n"
  let sql .= "UPDATE memos SET modified = DATETIME('now','localtime') WHERE path = ?;\n"
  call add(params, a:path)
  call add(params, a:title)
  call add(params, a:path)

  " tags
  if !empty(a:tags)
    let sql .= "REPLACE INTO memo_tags(memo_path, tags) VALUES(?, ?);\n"
    call add(params, a:path)
    call add(params, join(a:tags))

    for tag in a:tags
      let sql .= "REPLACE INTO tags(name, memo_count) VALUES(?, (SELECT count(memo_path) FROM memo_tags WHERE tags MATCH ?));"
      call add(params, tag)
      call add(params, tag)
    endfor
  endif

  let sql .= "COMMIT;\n"

  try
    call w#database#query(sql, params)
    return 1
  catch
    call w#database#query('ROLLBACK;')
    return 0
  endtry
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker: