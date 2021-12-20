if exists("g:loaded_CSSTocPlugin")
    finish
elseif v:version < 704
    finish
endif

let g:loaded_CSSTocPlugin = 1

if !exists("g:vct_auto_update_on_save")
    let g:vct_auto_update_on_save = 1
endif

if !exists("g:vct_dont_insert_fence")
    let g:vct_dont_insert_fence = 0
endif

if !exists("g:vct_fence_text")
    let g:vct_fence_text = 'BEGIN - Table of Contents'
endif

if !exists("g:vct_fence_closing_text")
    let g:vct_fence_closing_text = 'END   - Table of Contents'
endif

if !exists("g:vct_list_item_char")
    let g:vct_list_item_char = '*'
endif

if !exists("g:vct_list_indent_text")
    let g:vct_list_indent_text = ''
endif

if !exists("g:vct_cycle_list_item_markers")
    let g:vct_cycle_list_item_markers = 1
endif

if !exists("g:vct_include_headings_before")
    let g:vct_include_headings_before = 0
endif

if !exists("g:vct_min_level")
    let g:vct_min_level = 0
endif

if !exists("g:vct_max_level")
    let g:vct_max_level = 20
endif

let g:GFMHeadingIds = {}

function! s:HeadingLineRegex()
    return '\/\*\ #\([^*]\|[\r\n]\|\(\*\+\([^*/]\|[\r\n]\)\)\)*\*\+'
endfunction

function! s:GetHeadingLines()
    let l:winview = winsaveview()
    let l:headingLines = []

    let l:flags = "W"
    if g:vct_include_headings_before == 1
        keepjumps normal! gg0
        let l:flags = "Wc"
    endif

    let l:headingLineRegex = <SID>HeadingLineRegex()

    while search(l:headingLineRegex, l:flags) != 0
        let l:line = getline(".") 
        let l:lineNum = line(".")
        let l:flags = "W"
        call add(l:headingLines, l:line)
    endwhile

    call winrestview(l:winview)

    return l:headingLines
endfunction

function! s:GetHeadingName(headingLine)
    let l:headingName = substitute(a:headingLine, '*', '', 'g')
    let l:headingName = substitute(l:headingName, '/', '', 'g')
    let l:headingName = substitute(l:headingName, '\n', '', 'g')
    let l:headingName = substitute(l:headingName, '\r', '', 'g')
    let l:headingName = substitute(l:headingName, '\s\+$', '', 'g')
    let l:headingName = substitute(l:headingName, '\#', '', 'g')

    return l:headingName
endfunction

function! s:GenToc()
    call <SID>GenTocInner(0)
endfunction

function! s:GetHeadingLevel(headingLine)
    let l:count=0
    let l:count_h1=match(a:headingLine, '* \#')
    let l:count_h2=match(a:headingLine, '* \#\#')
    let l:count_h3=match(a:headingLine, '* \#\#\#')
    let l:count_h4=match(a:headingLine, '* \#\#\#\#')
    let l:count_h5=match(a:headingLine, '* \#\#\#\#\#')
    let l:count_h6=match(a:headingLine, '* \#\#\#\#\#\#')
    if l:count_h1 != -1
        let l:count+=l:count_h1
    endif
    if l:count_h2 != -1
        let l:count+=l:count_h2
    endif
    if l:count_h3 != -1
        let l:count+=l:count_h3
    endif
    if l:count_h4 != -1
        let l:count+=l:count_h4
    endif
    if l:count_h5 != -1
        let l:count+=l:count_h5
    endif
    if l:count_h6 != -1
        let l:count+=l:count_h6
    endif

    return l:count
endfunction

function! s:GenTocInner(isModeline)
    let l:headingLines = <SID>GetHeadingLines()
    let l:levels = []
    let l:listItemChars = [g:vct_list_item_char]

    let g:GFMHeadingIds = {}

    for headingLine in l:headingLines
        call add(l:levels, <SID>GetHeadingLevel(headingLine))
    endfor

    let l:minLevel = max([min(l:levels),g:vct_min_level])

    if g:vct_dont_insert_fence == 0
        silent put =<SID>GetBeginFence(a:isModeline)
    endif

    if g:vct_cycle_list_item_markers == 1
        let l:listItemChars = ['*', '-', '+']
    endif

    let l:i = 0
    " a black line before toc
    if !empty(l:headingLines)
       silent put =''
    endif

    for headingLine in l:headingLines
        let l:headingName = <SID>GetHeadingName(headingLine)
        " only add line if less than max level and greater than min level
        if l:levels[i] <= g:vct_max_level && l:levels[i] >= g:vct_min_level
            let l:headingIndents = l:levels[i] - l:minLevel
            let l:listItemChar = l:listItemChars[(l:levels[i] + 1) % len(l:listItemChars)]

            let l:heading = repeat(s:GetIndentText(), l:headingIndents)
            let l:heading = l:heading . l:listItemChar
            let l:heading = l:heading . " " . l:headingName

            silent put ='   ' . l:heading
        endif
        let l:i += 1
    endfor

    " a blank line after toc to avoid effect typo of content below
    silent put =''

    if g:vct_dont_insert_fence == 0
        silent put =<SID>GetEndFence()
    endif

endfunction

function! s:GetIndentText()
    if !empty(g:vct_list_indent_text)
        return g:vct_list_indent_text
    endif
    if &expandtab
        return repeat(" ", &shiftwidth)
    else
        return "\t"
    endif
endfunction

function! s:GetBeginFence(isModeline)
    if a:isModeline != 0
        return "/* " . g:vct_fence_text . " ==================================== *"
    else
        return "/* ". g:vct_fence_text . " ===================================== *"
    endif
endfunction

function! s:GetEndFence()
    return ' * ' . g:vct_fence_closing_text . " ==================================== */"
endfunction

function! s:GetBeginFencePattern(isModeline)
    if a:isModeline != 0
        return "/* " . g:vct_fence_text . " ==================================== *"
    else
        return "/* " . g:vct_fence_text . " \\([[:alpha:]]\\+\\)\\? \\?========= *"
    endif
endfunction

function! s:GetEndFencePattern()
    return g:vct_fence_closing_text
endfunction

function! s:GetCSSStyleInModeline()
    let l:myFileType = &filetype
    let l:lst = split(l:myFileType, "\\.")
    if len(l:lst) == 2 && l:lst[1] ==# "css"
        return l:lst[0]
    else
        return "Unknown"
    endif
endfunction

function! s:UpdateToc()
    let l:winview = winsaveview()

    let l:totalLineNum = line("$")

    let [l:beginLineNumber, l:endLineNumber, l:isModeline] = <SID>DeleteExistingToc()

    let l:isFirstLine = (l:beginLineNumber == 1)
    if l:beginLineNumber > 1
        let l:beginLineNumber -= 1
    endif

    if l:isFirstLine != 0
        call cursor(l:beginLineNumber, 1)
        put! =''
    endif

    call cursor(l:beginLineNumber, 1)
    call <SID>GenTocInner(1)

    if l:isFirstLine != 0
        call cursor(l:beginLineNumber, 1)
        delete _
    endif

    " fix line number to avoid shake
    if l:winview['lnum'] > l:endLineNumber
        let l:diff = line("$") - l:totalLineNum
        let l:winview['lnum'] += l:diff
        let l:winview['topline'] += l:diff
    endif

    call winrestview(l:winview)
endfunction

function! s:DeleteExistingToc()
    let l:winview = winsaveview()

    keepjumps normal! gg0

    let l:isModeline = 0

    let l:tocBeginPattern = <SID>GetBeginFencePattern(l:isModeline)
    let l:tocEndPattern = <SID>GetEndFencePattern()

    let l:beginLineNumber = -1
    let l:endLineNumber= -1

    if search(l:tocBeginPattern, "Wc") != 0
        let l:beginLine = getline(".")
        let l:beginLineNumber = line(".")
        echo l:beginLineNumber

        if search(l:tocEndPattern, "Wc") != 0
            let l:doDelete = 1

            if l:doDelete == 1
                let l:endLineNumber = line(".")
                silent execute l:beginLineNumber. "," . l:endLineNumber. "delete_"
            end
        else
            echom "Cannot find toc end fence"
        endif
    else
        echom "Cannot find toc begin fence"
    endif

    call winrestview(l:winview)

    return [l:beginLineNumber, l:endLineNumber, l:isModeline]
endfunction

command! GenToc :call <SID>GenToc()
command! GenTocModeline :call <SID>GenTocInner(1)
command! UpdateToc :call <SID>UpdateToc()
command! RemoveToc :call <SID>DeleteExistingToc()

if g:vct_auto_update_on_save == 1
    autocmd BufWritePre *.{css} if !&diff | exe ':silent! UpdateToc' | endif
endif

