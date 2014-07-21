let s:save_cpo = &cpo
set cpo&vim

function! w#feature#load_listeners(disable_features, notifier, key) "{{{
  let files = split(globpath(&runtimepath, 'autoload/w/features/*.vim'), '\n')

  for array_f in map(files, "w#features#{fnamemodify(v:val, ':t:r')}#load()")
    let a = []

    if type(array_f) == type({})
      call add(a, array_f)
    elseif type(array_f) == type([])
      let a = array_f
    endif

    for f in a
      if index(a:disable_features, f.name) != -1
        continue
      endif
      if has_key(f, a:key)
        for [name, Listener] in items(f[a:key])
          call a:notifier.add(name, Listener)
        endfor
      endif
    endfor

  endfor
endfunction "}}}

function! w#feature#load_menu(disable_features) "{{{
  let menu = []

  let files = split(globpath(&runtimepath, 'autoload/w/features/*.vim'), '\n')

  for array_f in map(files, "w#features#{fnamemodify(v:val, ':t:r')}#load()")
    let a = []

    if type(array_f) == type({})
      call add(a, array_f)
    elseif type(array_f) == type([])
      let a = array_f
    endif

    for f in a
      if index(a:disable_features, f.name) != -1
        continue
      endif
      if has_key(f, 'menu')
        for [menu_name, menu_context] in items(f.menu)
          if has_key(menu_context, 'callback') && type(menu_context.callback) == type(function('tr'))
            let m = {}
            let m.callback = menu_context.callback

            if has_key(menu_context, 'text')
              let m.text = menu_context.text
            else
              let m.text = menu_name
            endif

            call add(menu, m)
          endif
        endfor
      endif
    endfor

  endfor

  return menu
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
