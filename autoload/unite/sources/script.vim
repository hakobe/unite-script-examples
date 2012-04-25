" unite scripts with unite.vim
" see http://d.hatena.ne.jp/hakobe932

let s:source = {
\   'name': 'script',
\ }

let s:buffer = {
\   'path': expand('%'),
\ }

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
    let lines = split(system(printf("%s %s %s", runner, script, s:buffer.path)), "\n")
    return filter(map(lines, 's:create_candidate(v:val)'), 'len(v:val) > 0')
endfunction

function! unite#sources#script#define()
  return [s:source]
endfunction

