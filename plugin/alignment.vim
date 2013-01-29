" alignment.vim - Auto align the starting position of lines or the `=` position
" Author          Wang Chao <https://github.com/yueyoum>
" Started         2013-1-27
" Updated         2013-1-27
" Version         0.1.0


if exists("g:loaded_aligement") || &cp
    finish
endif
let g:loaded_aligement = 1



function! alignment#GetSeletedLines()
    let s:start_line = line("'<")
    let s:end_line = line("'>")

    if s:start_line == 0 && s:end_line == 0
        return []
    endif

    return getline(s:start_line, s:end_line)
endfunction


function! alignment#AlignStart()
    let s:selected_lines = alignment#GetSeletedLines()

    if len(s:selected_lines) == 0
        echoerr "no selections"
        return
    endif

    let s:max_start_pos = 0
    let s:line_start_pos = []

    for s:_line in s:selected_lines
        let s:this_max_start_pos = match(s:_line, "[^	 ]")
        let s:_ = add(s:line_start_pos, s:this_max_start_pos)
        if s:this_max_start_pos > s:max_start_pos
            let s:max_start_pos = s:this_max_start_pos
        endif
    endfor

    let s:start_line = line("'<'")
    for s:index in range(len(s:selected_lines))
        if s:selected_lines[s:index] == ''
            continue
        endif

        if s:line_start_pos[s:index] < s:max_start_pos
            let s:space_additions = repeat(' ', (s:max_start_pos - s:line_start_pos[s:index]))
            call setline(s:index + s:start_line, s:space_additions.s:selected_lines[s:index])
        endif
    endfor
endfunction



function! alignment#AlignEqualSymbol()
    let s:selected_lines = alignment#GetSeletedLines()

    if len(s:selected_lines) == 0
        echoerr "no selections"
        return
    endif

    let s:max_equal_pos = 0
    let s:line_equal_pos = []

    for s:_line in s:selected_lines

        let s:this_equal_pos = stridx(s:_line, "=")
        let s:_ = add(s:line_equal_pos, s:this_equal_pos)

        if s:this_equal_pos > s:max_equal_pos
            let s:max_equal_pos = s:this_equal_pos
        endif
    endfor

    let s:start_line = line("'<'")
    for s:index in range(len(s:selected_lines))
        if s:line_equal_pos[s:index] != -1 && s:line_equal_pos[s:index] < s:max_equal_pos
            let s:space_additions = repeat(' ', (s:max_equal_pos - s:line_equal_pos[s:index]))
            let s:_start_part = strpart(s:selected_lines[s:index], 0, s:line_equal_pos[s:index])
            let s:_end_part = strpart(s:selected_lines[s:index], s:line_equal_pos[s:index])
            call setline(s:index + s:start_line, s:_start_part.s:space_additions.s:_end_part)
        endif
    endfor
endfunction



vnoremap <silent> <Leader>[ : call alignment#AlignStart()<CR>gv
vnoremap <silent> <Leader>= : call alignment#AlignEqualSymbol()<CR>gv

