" unite scripts with unite.vim
" see http://d.hatena.ne.jp/hakobe932

let s:source = {
\   'name': 'script',
\   'hooks': {}
\ }

function! s:source.hooks.on_init(args, context)
    let s:buffer = {
        \ 'path'    : expand('%'),
        \ }
endfunction

function! s:create_candidate(val)
    let matches = matchlist(a:val, '^\(.*\)\t\(.*\)$')

    if len(matches) == 0
        return {"word": "none"}
    endif
    return {
    \   "word": matches[1],
    \   "source": "script",
    \   "kind": "command",
    \   "action__command": matches[2] 
    \ }
endfunction

function! s:source.gather_candidates(args, context)
    let runner = a:args[0]
    let script = a:args[1]
    if has("unix")
        let state = {}
        let state.fname = tempname()
        let state.complete = tempname()
        let a:context.source__state = state
        let cmd = printf("(%s %s %s > %s ; echo OK > %s)&",
              \ runner, script, s:buffer.path,
              \ state.fname, state.complete)
        call system(cmd)
        return []
    else
        let a:context.is_async = 0
        let lines = split(system(printf("%s %s %s", runner, script, s:buffer.path)), "\n")
        return filter(map(lines, 's:create_candidate(v:val)'), 'len(v:val) > 0')
    end
endfunction

function! s:source.async_gather_candidates(args, context)
    if !has("unix")
        let a:context.is_async = 0
        return []
    else
        if filereadable(a:context.source__state.complete) &&
              \ readfile(a:context.source__state.complete) == ["OK"]
            let a:context.is_async = 0
            let lines = readfile(a:context.source__state.fname)
            let result = filter(map(lines, 's:create_candidate(v:val)'), 'len(v:val) > 0')
            call delete(a:context.source__state.complete)
            call delete(a:context.source__state.fname)
            return result
        else
            return []
        end
    end
endfunction

function! unite#sources#script#define()
  return [s:source]
endfunction

