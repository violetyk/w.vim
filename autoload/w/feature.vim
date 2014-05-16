let s:save_cpo = &cpo
set cpo&vim

let s:features = []
let s:callbacks = w#callbacks#new()

function! w#feature#load_all() "{{{
  unlet! s:features
  let s:features = []

  let files = split(globpath(&rtp, 'autoload/w/features/*.vim'), '\n')

  for array_f in map(files, "w#features#{fnamemodify(v:val, ':t:r')}#load()")
    let a = []

    if type(array_f) == type({})
      call add(a, array_f)
    elseif type(array_f) == type([])
      let a = array_f
    endif

    for f in a
      if has_key(f, 'callbacks')
        for [target, context] in items(f.callbacks)
          let [name, Fn] = items(context)[0]
          let listener = [Fn, f.callbacks[target]]
          call call(printf("w#%s#add_callback", target), [name, listener])
        endfor
      endif
    endfor

  endfor

  call s:callbacks.notify('after_load')
endfunction "}}}

function! w#feature#list() "{{{
 echo s:features
endfunction "}}}

function! w#feature#add_callback(name, listener) "{{{
  return s:callbacks.add(a:name, a:listener)
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
