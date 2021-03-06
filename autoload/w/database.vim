let s:save_cpo = &cpo
set cpo&vim


" vital.vim
let s:V       = vital#of(g:w_of_vital)
let s:Message = s:V.import('Vim.Message')
let s:File    = s:V.import('System.File')
let s:DB      = s:V.import('Database.SQLite')
let s:JSON    = s:V.import('Web.JSON')

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

function! w#database#save_note(path, title, new_tags, old_tags) "{{{
  let path = w#database#modify_path(a:path)
  let sql = "BEGIN;\n"
  let params = []

  " UPSERT note
  let sql .= "INSERT OR IGNORE INTO notes(path, title) VALUES(?, ?);\n"
  call add(params, path)
  call add(params, a:title)
  let sql .= "UPDATE notes SET title = ?, modified = DATETIME('now','localtime') WHERE path = ?;\n"
  call add(params, a:title)
  call add(params, path)


  " UPSERT search_data
  let sql .= "DELETE FROM search_data WHERE note_path = ?;\n"
  call add(params, path)
  let sql .= "INSERT INTO search_data(note_path, tags) VALUES(?, ?);\n"
  call add(params, path)
  call add(params, join(a:new_tags))

  " UPDATE tags
  let tags = deepcopy(a:new_tags)
  if !empty(a:old_tags)
    let tags += a:old_tags
  endif
  for tag in tags
    let sql .= "INSERT OR REPLACE INTO tags(name, note_count) VALUES(?, (SELECT count(note_path) FROM search_data WHERE tags MATCH ?));\n"
    call add(params, tag)
    call add(params, tag)
  endfor
  let sql .= "DELETE FROM tags WHERE note_count = 0;\n"

  let sql .= "COMMIT;\n"
  try
    call w#database#query(sql, params)
    return 1
  catch
    call w#database#query('ROLLBACK;')
    return 0
  endtry
endfunction "}}}

function! w#database#delete_note(path) "{{{
  let path = w#database#modify_path(a:path)

  let sql = "BEGIN;\n"
  let params = []

  " get tags
  let result = w#database#query("SELECT tags FROM search_data WHERE note_path = ?;\n", [path])
  let tags = []
  if !empty(result) && has_key(result[0], 'tags') && result[0].tags != ''
    let tags = split(result[0].tags)
  endif

  let sql .= "DELETE FROM search_data WHERE note_path = ?;\n"
  call add(params, path)

  let sql .= "DELETE FROM notes WHERE path = ?;\n"
  call add(params, path)

  " UPDATE tags
  for tag in tags
    let sql .= "INSERT OR REPLACE INTO tags(name, note_count) VALUES(?, (SELECT count(note_path) FROM search_data WHERE tags MATCH ?));\n"
    call add(params, tag)
    call add(params, tag)
  endfor
  let sql .= "DELETE FROM tags WHERE note_count = 0;\n"

  let sql .= "COMMIT;\n"
  try
    call w#database#query(sql, params)
    return 1
  catch
    call w#database#query('ROLLBACK;')
    return 0
  endtry
endfunction "}}}

function! w#database#find_notes(option) "{{{
  let params = []
  let sql  = "SELECT path, title FROM notes\n"

  " where path
  if has_key(a:option, 'path')
    if type(a:option.path) == type([])
      let sql .= "WHERE path IN (?);\n"
      call add(params, join(a:option.path))
    else
      let sql .= "WHERE path = ?;\n"
      call add(params, a:option.path)
    endif
  endif

  " where tag
  if has_key(a:option, 'tag')
    let sql .= "WHERE path IN (SELECT note_path FROM search_data WHERE tags MATCH ?);\n"
    call add(params, a:option.tag)
  endif

  " order by
  let sql .= "ORDER BY modified DESC\n"

  " limit
  if has_key(a:option, 'limit')
    let sql .= "LIMIT ?\n"
    call add(params, a:option.limit)
  endif

  let sql .= ";"
  return w#database#query(sql, params)
endfunction "}}}

function! w#database#find_mru_tags(limit) "{{{
  let sql = 'SELECT name, note_count FROM tags ORDER BY modified DESC LIMIT ?;'
  return w#database#query(sql, [a:limit])
endfunction "}}}

function! w#database#find_all_tags() "{{{
  let sql = 'SELECT name, note_count FROM tags ORDER BY name ASC;'
  return w#database#query(sql, [])
endfunction "}}}

function! w#database#modify_path(path) "{{{
  return fnamemodify(a:path, ':s?' . g:w#settings.note_dir() . '??')
endfunction "}}}

function! w#database#get_note_context(path, key) "{{{
  let path = w#database#modify_path(a:path)
  let result = w#database#query("SELECT context FROM notes WHERE path = ?;\n", [path])
  if !empty(result) && has_key(result[0], 'context') && result[0].context != ''
    let context = {}
    try
      let context = s:JSON.decode(result[0].context)
    catch
    endtry

    return get(context, a:key, '')
  endif

  return ''
endfunction "}}}

function! w#database#set_note_context(path, key, value) "{{{
  let path = w#database#modify_path(a:path)
  let result = w#database#query("SELECT context FROM notes WHERE path = ?;\n", [path])

  if !empty(result) && has_key(result[0], 'context')
    let context = {}
    try
      let context = s:JSON.decode(result[0].context)
    catch
    endtry

    let context[a:key] = a:value
    try
      let sql = "UPDATE notes SET context = ?, modified = DATETIME('now','localtime') WHERE path = ?;\n"
      call w#database#query(sql, [s:JSON.encode(context), path])
      return 1
    catch
    endtry
  endif

  return 0
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
