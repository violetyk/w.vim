let s:save_cpo = &cpo
set cpo&vim

function! w#callbacks#new()
  let self = {}
  let self._callbacks = {}

  function! self.initialize() "{{{
    unlet! self._callbacks
    let self._callbacks = {}
  endfunction "}}}
  function! self.add(name, listener) "{{{
    if !has_key(self._callbacks, a:name)
      let self._callbacks[a:name] = []
    endif
    return add(self._callbacks[a:name], a:listener)
  endfunction "}}}
  function! self.notify(name, ...) "{{{

    if !has_key(self._callbacks, a:name)
      return
    endif

    for listener in self._callbacks[a:name]
      if type(listener) == type(function('type'))
        let Fn = listener
        call call(Fn, a:000)
      elseif type(listener) == type([])
        let Fn = listener[0]
        let dict = listener[1]
        call call(Fn, a:000, dict)
      endif
    endfor
  endfunction "}}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
