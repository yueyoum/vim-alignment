" alignment.vim - Auto align what you want!
" Author          Wang Chao <https://github.com/yueyoum>
" Started         2013-1-27
" Updated         2013-1-31
" Version         0.2.0


if exists("g:loaded_alignment") || &cp
    finish
endif
let g:loaded_alignment = 1



" Align the start position of selected lines
function! alignment#AlignHead(startline, endline)
    let s:selected_lines = getline(a:startline, a:endline)

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

    for s:index in range(len(s:selected_lines))
        if s:selected_lines[s:index] == ''
            continue
        endif

        if s:line_start_pos[s:index] < s:max_start_pos
            let s:space_additions = repeat(' ', (s:max_start_pos - s:line_start_pos[s:index]))
            call setline(s:index + a:startline, s:space_additions.s:selected_lines[s:index])
        endif
    endfor
endfunction



" Align any char which inputed by user
function! alignment#AlignChar(startline, endline, char)
    let s:selected_lines = getline(a:startline, a:endline)

    if len(s:selected_lines) == 0
        echoerr "no selections"
        return
    endif

    let s:max_symbol_pos = 0
    let s:line_symbol_pos = []

    for s:_line in s:selected_lines
        let s:this_symbol_pos = stridx(s:_line, a:char)
        if s:this_symbol_pos >= 0
            " DO NOT PROCESS '==' with '='
            if a:char == '=' && s:_line[s:this_symbol_pos + 1] == '='
                let s:this_symbol_pos = -1
            endif
        endif

        let s:_ = add(s:line_symbol_pos, s:this_symbol_pos)

        if s:this_symbol_pos > s:max_symbol_pos
            let s:max_symbol_pos = s:this_symbol_pos
        endif
    endfor

    for s:index in range(len(s:selected_lines))
        if s:line_symbol_pos[s:index] != -1 && s:line_symbol_pos[s:index] < s:max_symbol_pos
            let s:space_additions = repeat(' ', (s:max_symbol_pos - s:line_symbol_pos[s:index]))
            let s:_start_part = strpart(s:selected_lines[s:index], 0, s:line_symbol_pos[s:index])
            let s:_end_part = strpart(s:selected_lines[s:index], s:line_symbol_pos[s:index])
            call setline(s:index + a:startline, s:_start_part.s:space_additions.s:_end_part)
        endif
    endfor
endfunction



function! alignment#AlignmentStart() range
    echohl Question
    echo "Align char: "
    echohl None


    let s:char = getchar()
    redraw

    if s:char == 27
        " ESC
        echo "Cancelled"
    else
        let s:char = nr2char(s:char)
        if s:char == '['
            call alignment#AlignHead(a:firstline, a:lastline)
        else
            call alignment#AlignChar(a:firstline, a:lastline, s:char)
        endif
        echo 'Done'
    endif
    
    execute "normal! gv"
    return ''
endfunction


vnoremap <silent><Leader>[ : call alignment#AlignmentStart()<CR>
vnoremap <silent><Leader>= : call alignment#AlignmentStart()<CR>=

