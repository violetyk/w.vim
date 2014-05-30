let s:save_cpo = &cpo
set cpo&vim

function! w#feature#load_all(disable_features, event_manager) "{{{
  let files = split(globpath(&rtp, 'autoload/w/features/*.vim'), '\n')

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
      if has_key(f, 'events')
        for [name, Listener] in items(f.events)
          call a:event_manager.add(name, Listener)
        endfor
      endif
    endfor

  endfor
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
