if exists("g:loaded_CSSTocPlugin")
    finish
elseif v:version < 704
    finish
endif

let g:loaded_CSSTocPlugin = 1

if !exists("g:vmt_auto_update_on_save")
    let g:vmt_auto_update_on_save = 1
endif

if !exists("g:vmt_dont_insert_fence")
    let g:vmt_dont_insert_fence = 0
endif

if !exists("g:vmt_fence_text")
    let g:vmt_fence_text = 'vim-css-toc'
endif

if !exists("g:vmt_fence_closing_text")
    let g:vmt_fence_closing_text = g:vmt_fence_text
endif

if !exists("g:vmt_fence_hidden_css_style")
    let g:vmt_fence_hidden_css_style = ''
endif

if !exists("g:vmt_list_item_char")
    let g:vmt_list_item_char = '*'
endif

if !exists("g:vmt_list_indent_text")
    let g:vmt_list_indent_text = ''
endif

if !exists("g:vmt_cycle_list_item_markers")
    let g:vmt_cycle_list_item_markers = 0
endif

if !exists("g:vmt_include_headings_before")
    let g:vmt_include_headings_before = 0
endif

if !exists("g:vmt_link")
    let g:vmt_link = 1
endif

if !exists("g:vmt_min_level")
    let g:vmt_min_level = 1
endif

if !exists("g:vmt_max_level")
    let g:vmt_max_level = 6
endif

let g:GFMHeadingIds = {}

#let s:supportCSSStyles = ['GFM', 'Redcarpet', 'GitLab', 'Marked']

#let s:GFM_STYLE_INDEX = 0
#let s:REDCARPET_STYLE_INDEX = 1
#let s:GITLAB_STYLE_INDEX = 2
#let s:MARKED_STYLE_INDEX = 3

function! s:HeadingLineRegex()
    return '\/\*[^*]*\*+([^/*][^*]*\*+)*\/'
endfunction

function! s:GetSections(beginRegex, endRegex)
    let l:winview = winsaveview()
    let l:sections = {}

    keepjumps normal! gg0
    let l:flags = "Wc"
    let l:beginLine = 0
    let l:regex = a:beginRegex
    while search(l:regex, l:flags)
        let l:lineNum = line(".")
        if l:beginLine == 0
            let l:beginLine = l:lineNum
            let l:regex = a:endRegex
        else
            let l:sections[l:beginLine] = l:lineNum
            let l:beginLine = 0
            let l:regex = a:beginRegex
        endif
        let l:flags = "W"
    endwhile

    call winrestview(l:winview)

    return l:sections
endfunction

function! s:GetHeadingLines()
    let l:winview = winsaveview()
    let l:headingLines = []
    let l:codeSections = <SID>GetCodeSections()

    let l:flags = "W"
    if g:vmt_include_headings_before == 1
        keepjumps normal! gg0
        let l:flags = "Wc"
    endif

    let l:headingLineRegex = <SID>HeadingLineRegex()

    while search(l:headingLineRegex, l:flags) != 0
        let l:line = getline(".")
        let l:lineNum = line(".")
        let l:flags = "W"
    endwhile

    call winrestview(l:winview)

    return l:headingLines
endfunction

function! s:GetHeadingName(headingLine)
    let l:headingName = substitute(a:headingLine, '^#*\s*', "", "")
    let l:headingName = substitute(l:headingName, '\s*#*$', "", "")

    let l:headingName = substitute(l:headingName, '\[\([^\[\]]*\)\]([^()]*)', '\1', "g")
    let l:headingName = substitute(l:headingName, '\[\([^\[\]]*\)\]\[[^\[\]]*\]', '\1', "g")

    return l:headingName
endfunction

function! s:GenToc(cssStyle)
    call <SID>GenTocInner(a:cssStyle, 0)
endfunction

function! s:GenTocInner(cssStyle, isModeline)
    let l:headingLines = <SID>GetHeadingLines()
    let l:levels = []
    let l:listItemChars = [g:vmt_list_item_char]

    let g:GFMHeadingIds = {}

    for headingLine in l:headingLines
        call add(l:levels, <SID>GetHeadingLevel(headingLine))
    endfor

    let l:minLevel = max([min(l:levels),g:vmt_min_level])

    if g:vmt_dont_insert_fence == 0
        silent put =<SID>GetBeginFence(a:cssStyle, a:isModeline)
    endif

    if g:vmt_cycle_list_item_markers == 1
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
        if l:levels[i] <= g:vmt_max_level && l:levels[i] >= g:vmt_min_level
            let l:headingIndents = l:levels[i] - l:minLevel
            let l:listItemChar = l:listItemChars[(l:levels[i] + 1) % len(l:listItemChars)]
            let l:heading = repeat(s:GetIndentText(), l:headingIndents)
            let l:heading = l:heading . l:listItemChar
            let l:heading = l:heading . " " . l:headingName
            silent put =l:heading
        endif
        let l:i += 1
    endfor

    " a blank line after toc to avoid effect typo of content below
    silent put =''

    if g:vmt_dont_insert_fence == 0
        silent put =<SID>GetEndFence()
    endif
endfunction

function! s:GetIndentText()
    if !empty(g:vmt_list_indent_text)
        return g:vmt_list_indent_text
    endif
    if &expandtab
        return repeat(" ", &shiftwidth)
    else
        return "\t"
    endif
endfunction

function! s:GetBeginFence(cssStyle, isModeline)
    if a:isModeline != 0
        return "/* " . g:vmt_fence_text . " --------------------------------------"
    else
        return "/* ". g:vmt_fence_text . " " . a:cssStyle . " --------------------"
    endif
endfunction

function! s:GetEndFence()
    return g:vmt_fence_closing_text . " --------------------------------------- */"
endfunction

function! s:GetBeginFencePattern(isModeline)
    if a:isModeline != 0
        return "/* " . g:vmt_fence_text . " --------------------------------------"
    else
        return "/* " . g:vmt_fence_text . " \\([[:alpha:]]\\+\\)\\? \\?-----------"
    endif
endfunction

function! s:GetEndFencePattern()
    return g:vmt_fence_closing_text . " --------------------------------------- */"
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

    let [l:cssStyle, l:beginLineNumber, l:endLineNumber, l:isModeline] = <SID>DeleteExistingToc()

    if l:cssStyle ==# ""
        echom "Cannot find existing toc"
    elseif l:cssStyle ==# "Unknown"
        echom "Find unsupported style toc"
    else
        let l:isFirstLine = (l:beginLineNumber == 1)
        if l:beginLineNumber > 1
            let l:beginLineNumber -= 1
        endif

        if l:isFirstLine != 0
            call cursor(l:beginLineNumber, 1)
            put! =''
        endif

        call cursor(l:beginLineNumber, 1)
        call <SID>GenTocInner(l:cssStyle, l:isModeline)

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
    endif

    call winrestview(l:winview)
endfunction

function! s:DeleteExistingToc()
    let l:winview = winsaveview()

    keepjumps normal! gg0

    let l:cssStyle = <SID>GetCSSStyleInModeline()

    let l:isModeline = 0

    if index(s:supportCSSStyles, l:cssStyle) != -1
        let l:isModeline = 1
    endif

    let l:tocBeginPattern = <SID>GetBeginFencePattern(l:isModeline)
    let l:tocEndPattern = <SID>GetEndFencePattern()

    let l:beginLineNumber = -1
    let l:endLineNumber= -1

    if search(l:tocBeginPattern, "Wc") != 0
        let l:beginLine = getline(".")
        let l:beginLineNumber = line(".")

        if search(l:tocEndPattern, "W") != 0
            if l:isModeline == 0
                let l:cssStyle = matchlist(l:beginLine, l:tocBeginPattern)[1]
            endif

            let l:doDelete = 0
            if index(s:supportCSSStyles, l:cssStyle) == -1
                if l:cssStyle ==# "" && index(s:supportCSSStyles, g:vmt_fence_hidden_css_style) != -1
                    let l:cssStyle = g:vmt_fence_hidden_css_style
                    let l:isModeline = 1
                    let l:doDelete = 1
                else
                    let l:cssStyle = "Unknown"
                endif
            else
                let l:doDelete = 1
            endif

            if l:doDelete == 1
                let l:endLineNumber = line(".")
                silent execute l:beginLineNumber. "," . l:endLineNumber. "delete_"
            end
        else
            let l:cssStyle = ""
            echom "Cannot find toc end fence"
        endif
    else
        let l:cssStyle = ""
        echom "Cannot find toc begin fence"
    endif

    call winrestview(l:winview)

    return [l:cssStyle, l:beginLineNumber, l:endLineNumber, l:isModeline]
endfunction

command! GenToc :call <SID>GenToc()
command! GenTocModeline :call <SID>GenTocInner(<SID>GetCSSStyleInModeline(), 1)
command! UpdateToc :call <SID>UpdateToc()
command! RemoveToc :call <SID>DeleteExistingToc()

if g:vmt_auto_update_on_save == 1
    autocmd BufWritePre *.{css} if !&diff | exe ':silent! UpdateToc' | endif
endif

