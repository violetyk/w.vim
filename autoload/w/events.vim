let s:save_cpo = &cpo
set cpo&vim

function! w#events#new()
  let self = {}
  let self._events = {}

  function! self.initialize() "{{{
    unlet! self._events
    let self._events = {}
  endfunction "}}}

  function! self.add(name, listener) "{{{
    if !has_key(self._events, a:name)
      let self._events[a:name] = []
    endif
    return add(self._events[a:name], a:listener)
  endfunction "}}}

  function! self.notify(name, ...) "{{{
    if !has_key(self._events, a:name)
      return
    endif

    for Listener in self._events[a:name]
      if type(Listener) == type(function('type'))
        call call(Listener, a:000, self._events)
      endif
    endfor
  endfunction "}}}

  return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
