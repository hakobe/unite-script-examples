" script.vim

let s:source = {
\   'name': 'script',
\ }

function! s:source.on_init(args, context)
    let s:buffer = {
        \ 'path'    : expand('%'),
        \ }
endfunction

function! s:get_word(line)

    let word = (split(a:line, ","))[0]
    return word
endfunction

function! s:get_command(line)
    let command = (split(a:line, ","))[1]
    return command
endfunction

function! s:source.gather_candidates(args, context)
    if len(a:args) <2 
        call unite#print_error("please specify runner and script")
        return []
    endif

    let runner = a:args[0]
    let script = a:args[1]
    let lines = split(system(printf("%s %s %s", runner, script, s:buffer.path)), "\n")
    return map(lines, '{
    \   "word": s:get_word(v:val),
    \   "source": "script",
    \   "kind": "command",
    \   "action__command": s:get_command(v:val),
    \ }')
endfunction

function! unite#sources#script#define()
  return [s:source]
endfunction

