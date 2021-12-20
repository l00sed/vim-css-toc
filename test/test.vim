exec "silent! source " . "../ftplugin/css.vim"

let g:caseCount = 0
let g:passCaseCount = 0
let g:errorCaseCount = 0

function! ASSERT(var)
    let g:caseCount += 1
    if a:var != 0
        let g:passCaseCount += 1
        echo "case " . g:caseCount . " pass"
    else
        let g:errorCaseCount += 1
        echoe "case " . g:caseCount . " error"
    endif
endfunction

"call ASSERT()

echo "" . g:passCaseCount . " cases pass, " . g:errorCaseCount . " cases error"
