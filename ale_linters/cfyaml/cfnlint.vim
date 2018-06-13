
" Author: James Seward <james@jamesoff.net>

let g:ale_cfyaml_cfnlint_executable =
\   get(g:, 'ale_cfyaml_cfnlint_executable', 'cfn-lint')

let g:ale_cfyaml_cfnlint_options =
\   get(g:, 'ale_cfyaml_cfnlint_options', '')

function! ale_linters#cfyaml#cfnlint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cfyaml_cfnlint_executable')
endfunction

function! ale_linters#cfyaml#cfnlint#GetCommand(buffer) abort
    return ale_linters#cfyaml#cfnlint#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'cfyaml_cfnlint_options')
    \   . ' --format parseable --template %t'
endfunction

function! ale_linters#cfyaml#cfnlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
	" cloudformation/cloud.yaml:41:3:41:15: [W8001] Condition NoRoute53DNS not used
    "let l:pattern = '^.*:\(\d\+\):\(\d\+\): \[\(error\|warning\)\] \(.\+\)$'
	let l:pattern = '^.*:\(\d\+\):\(\d\+\):\(\d\+\):\(\d\+\): \[\(.\)\(\d\+\)\] \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[1]
        let l:col = l:match[2]
		let l:endline = l:match[3]
		let l:endcol = l:match[4]
        let l:type = l:match[5]
        let l:text = '[' . l:match[5] . l:match[6] . '] ' . l:match[7]

        call add(l:output, {
        \   'lnum': l:line,
        \   'col': l:col,
		\   'end_lnum': l:endline,
		\	'end_col': l:endcol,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('cfyaml', {
\   'name': 'cfnlint',
\   'executable_callback': 'ale_linters#cfyaml#cfnlint#GetExecutable',
\   'command_callback': 'ale_linters#cfyaml#cfnlint#GetCommand',
\   'callback': 'ale_linters#cfyaml#cfnlint#Handle'
\})
