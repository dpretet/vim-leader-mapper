"---------------------------------------------------------------
" Plugin:      https://github.com/dpretet/vim-leader-mapper
" Description: A plugin to create a leader key menu
" Maintainer:  Damien Pretet https://github.com/dpretet
"---------------------------------------------------------------

" Save compatible mode
let s:save_cpo = &cpo
" Reset compatible mode to default value
set cpo&vim

" Startup function to call the plugin from user land
function! leaderMapper#start(...)

    if g:leaderMapperDebug
        echom "DEBUG: vim-leader-mapper - Start"
    endif

    if (a:0 == 2)
        if g:leaderMapperDebug
            echom "       Line start: ".a:1
            echom "       Line end: ".a:2
        endif
        let g:leaderMapperLineStart = a:1
        let g:leaderMapperLineEnd = a:2
    endif

    if has('nvim')
        call s:LoadMenu(g:leaderMenu)
    else
        echom "INFO: vim-leader-mapper - Only supports Neovim!"
    endif

    " Initialize the strart & end variables to avoid bad behavior
    " of commands/functions on next call
    let g:leaderMapperLineStart = -1
    let g:leaderMapperLineEnd = -1


endfunction


" Load menu, meaning create the buffer, display the window
" and populate the content with leaderMenu configuration
function! s:LoadMenu(leaderMenu)

    " Create the string menu to fill the buffer to display
    call s:FillMenu(a:leaderMenu)
    " Open the window menu
    call s:OpenMenu()
    " Wait user actions
    call s:WaitUserAction(a:leaderMenu)

endfunction


" Open floating window where menu is displayed. Neovim only
function! s:OpenMenu()

    if g:leaderMapperPos != "center" && g:leaderMapperPos != "top" && g:leaderMapperPos != "bottom"
        echo "WARNING: vim-leader-mapper plugin - g:leaderMapperPos is not correct (can be top/bottom/center)"
        let g:leaderMapperPos = "center"
    endif

    if g:leaderMapperDebug
        echom "DEBUG: vim-leader-mapper - open window"
    endif

    "From menu dimension compute the window size & placement
    let height = len(s:leaderMenu)

    " Handles the window position
    if g:leaderMapperPos == "top"
        let row = 2  " 2 to put the window slightly below the window's top
    elseif g:leaderMapperPos == "bottom"
        let row = &lines - height - 4 " -4 to avoid status line overlap
    else
        let row  = (&lines - height) / 2
    endif

    " Use row 3 because 0 is the title, 1 is a blank line
    " -3 to put window limit closed to border
    let width = len(s:leaderMenu[3]) - 3
    let col = (&columns - width) / 2

    " Set the position, size, ... of the floating window.
    let opts = {
                \ 'relative': 'editor',
                \ 'row': row,
                \ 'col': col,
                \ 'width': width,
                \ 'height': height
                \ }

    " Open floating windows to display our menu
    let s:win = nvim_open_win(s:menuBuffer, v:true, opts)
    " Set floating window highlighting
    call setwinvar(s:win, '&winhl', 'Normal:Normal')

    setlocal colorcolumn=
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal bufhidden=hide
    setlocal nonumber
    setlocal norelativenumber
    setlocal signcolumn=no
    setlocal foldcolumn=0

endfunction


" Return the name of the longest string in a list
function! s:GetLongestLine(list)

    let len = 0
    " Simply parse one by one the line and check if
    " its length is the longest
    for line in a:list
        let _temp = len(line)
        if _temp > len
            let len = _temp
        endif
    endfor

    return len

endfunction


" Close leader menu and free the buffer
function! s:CloseMenu()

    " Delete menu's buffer
    if exists('s:menuBuffer')
        unlet s:menuBuffer
    endif

    " Close window (force)
    call nvim_win_close(s:win, 1)
    " Free the window's handle
    unlet s:win

    if g:leaderMapperDebug
        echom "DEBUG: vim-leader-mapper - close window and delete buffer"
    endif

endfunction


" Wait for user action to decide next steps
function! s:WaitUserAction(leaderMenu)

    " redraw to force display of menu (hidden by default with getchar call)
    redraw
    let userAction = ""
    let notCommand = 1

    while (notCommand)

        " wait for a user character input. Return ASCII code
        let userInput = getchar()
        " Convert to string
        let userInput = nr2char(userInput)
        let userAction = userAction . userInput

        " Break the loop if command recognized
        if has_key(a:leaderMenu, userAction)
            call s:CloseMenu()
            let notCommand = 0
        endif

        " Give up if receive ctrl-c or escape
        if userInput == "\<c-c>" || userInput == "\e"
            call s:CloseMenu()
            return
        endif

    endwhile

    if g:leaderMapperDebug
        echom "DEBUG: vim-leader-mapper - User choice: ".userAction
    endif

    " Retrieve command and execute it
    call s:ExecCommand(a:leaderMenu, userAction)

endfunction


" Read leaderMenu and fill the menu's buffer
function! s:FillMenu(leaderMenu)

    " Window buffer, delete first if exists
    if exists('s:menuBuffer')
        unlet s:menuBuffer
    endif

    " Convert the conf into a list of string and create/fill the buffer
    let s:leaderMenu = s:CreateMenu(a:leaderMenu)
    let s:menuBuffer = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:menuBuffer, 0, 0, 0, s:leaderMenu)
    call nvim_buf_set_option(s:menuBuffer, 'filetype', 'leaderMapper')

endfunction


" Parse leaderMenu and create a list of string to display
function! s:CreateMenu(leaderMenu)

    " Menu title
    let title = ""
    let strMenu = []

    let max_key_len = 1
    " First add the different user configuration
    for [key, val] in items(a:leaderMenu)
        if key != "name"
            if strlen(key) > max_key_len
                let max_key_len = strlen(key)
            endif
        endif
    endfor

    " Then add the different user configuration
    for [key, val] in items(a:leaderMenu)
        if key != "name"
            " Extract description (ix 0 = cmd, ix 1 = description)
            " and add a space margin
            let str = repeat(" ", max_key_len - strlen(key)). key . " -> " . val[1]
            call add(strMenu, str)
        endif
    endfor

    " Put in shape the menu
    let menuLayout = s:DoMenuLayout(strMenu)

    " Then parse the menu to search for a name
    for [key, val] in items(a:leaderMenu)
        if key == "name" && !empty(val)
            let title = val
        endif
    endfor

    " If title doesn't exist, simply name it 'Menu'
    if empty(title)
        let title = " Leader Key Menu"
    endif

    " Append as first element the menu title and a blank on last line
    let finalMenu = [title, ""] + menuLayout + [""]
    return finalMenu

endfunction


" Used to create the final layout of the menu,
" by arranging the entry over the full window space
function! s:DoMenuLayout(menuContent)

    " Sort list with alphabetic order and ignore case
    let sortedMenu = sort(a:menuContent, "i")
    " Get max len of menu items
    let lenMax = s:GetLongestLine(a:menuContent)
    " Compute window width and item nb per line
    let winLen = (&columns * g:leaderMapperWidth / 100)
    " Maximum per line
    let maxItem = winLen / lenMax
    " Check nb of entry to insert and shorten maxItem
    " to avoid crashing the loop
    if len(sortedMenu) < maxItem
        let maxItem = len(sortedMenu)
    endif
    " Maxim item len allowed per column
    let maxItemLen = float2nr(ceil(winLen / maxItem))
    " Create the final menu based on maximum item per row. Append first the border
    let finalMenu = [" ╭" . repeat("─", (maxItem * maxItemLen) + 1) . "╮"]
    let tempItem = " │ "

    let iLen = 0
    " Concatenate the items to display several by line as
    " long it fits into the window
    for item in sortedMenu
        " Get number of space to append
        let itemLen = len(item)
        let missingLen = maxItemLen - itemLen
        " Append whitespace to have equal length entries
        let newItem = item . repeat(" ", missingLen)
        let tempItem = tempItem . newItem
        " If matched the num of item per line, append and continue
        let iLen += 1
        if iLen == maxItem
            call add(finalMenu, tempItem . "│")
            let tempItem = " │ "
            let iLen = 0
        " if reach the last item, add it
        elseif item == sortedMenu[-1]
            let missingLen = (maxItem - iLen) * maxItemLen
            let tempItem = tempItem . repeat(" ", missingLen)
            call add(finalMenu, tempItem . "│")
        endif

    endfor

    " Append bottom and return the formatted menu
    let bottom = " ╰" . repeat("─", (maxItem * maxItemLen) + 1) . "╯"
    call add(finalMenu, bottom)
    return finalMenu

endfunction


" Execute command requested by user
function! s:ExecCommand(leaderMenu, cmd)

    " Extract command (ix 0 = cmd, ix 1 = description)
    let choice = get(a:leaderMenu, a:cmd)[0]
    " Check if is a dict, so a sub-menu
    if type(choice) == 4
        if g:leaderMapperDebug
            echom "DEBUG: vim-leader-mapper - enter sub-menu"
        endif
        call s:LoadMenu(choice)
    " Else run the command
    else
        if g:leaderMapperDebug
            echom "DEBUG: vim-leader-mapper - execute ".choice
        endif
        execute choice
    endif

endfunction


" Restore compatible mode
let &cpo = s:save_cpo
unlet s:save_cpo
