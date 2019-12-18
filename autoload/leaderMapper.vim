"---------------------------------------------------------------
" Plugin:      https://github.com/damofthemoon/vim-leader-mapper
" Description: A plugin to create a leader key menu
" Maintainer:  Damien Pretet https://github.com/damofthemoon
"---------------------------------------------------------------

" Save compatible mode
let s:save_cpo = &cpo
" Reset compatible mode to default value
set cpo&vim

" Startup function to call the plugin from user land
function! leaderMapper#start()

    " Exit if user forgot to define a menu
    if !exists('g:leaderMenu')
        echoerr "ERROR: vim-leader-mapper plugin - No menu defined in user configuration!"
        return
    endif

    " For first launch, start from uppest menu level.
    let s:menuLevel = 'main'
    " Launch rendering
    call s:LoadMenu()

endfunction


" Load menu, meaning create the buffer, display the window
" and populate the content with g:leaderMenu configuration
function! s:LoadMenu()

    " Create the string menu to fill the buffer to display
    call s:FillMenu()
    " Open the window menu
    call s:OpenMenu()
    " Wait user actions
    call s:WaitUserAction()

endfunction


" Display the leader key menu
function! s:OpenMenu()
    if has('nvim')
        call s:OpenNeovimWin()
    else
        call s:OpenVimWin()
    endif
endfunction


" Open floating window where menu is displayed. Neovim only
function! s:OpenNeovimWin()

    if g:leaderMapperPos != "center"
        echo "WARNING: vim-leader-mapper plugin - g:leaderMapperPos is not correct (can be top/bottom/center)"
    endif

    "From menu dimension compute the window size & placement
    let height = len(s:menuList)

    " Handles the window position
    if g:leaderMapperPos == "top"
        let row = 2
    elseif g:leaderMapperPos == "bottom"
        let row = &lines - height - 4 " to avoid overlap status line
    else
        let row  = (&lines - height) / 2
    endif

    " Use row 2 because 0 is the title, 1 is a blank line
    " -3 to put window limit closed to border
    let width = len(s:menuList[3]) - 3
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
    call setwinvar(s:win, '&winhl', 'Normal:Pmenu')

    setlocal colorcolumn=
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal bufhidden=hide
    setlocal nonumber
    setlocal norelativenumber
    setlocal signcolumn=no

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


" Open popup window where menu is displayed. Vim only
function! s:OpenVimWin()
    " TODO: Populate for Vim 8
endfunction


" Close leader menu and free the buffer
function! s:CloseMenu()

    " Delete menu's buffer
    if exists('s:menuBuffer')
        unlet s:menuBuffer
    endif

    " Close menu window
    if has('nvim')
        call s:CloseNeovimMenu()
    else
        call s:CloseVimMenu()
    endif

endfunction


function s:CloseNeovimMenu()

    " Close window (force)
    call nvim_win_close(s:win, 1)
    " Free the window's handle
    unlet s:win

endfunction


function! s:CloseVimMenu()
    " TODO: populate for Vim
endfunction


" Wait for user action to decide next steps
function! s:WaitUserAction()

    " redraw to force display of menu (hidden by default with getchar call)
    redraw
    " wait for a user character input. Return ASCII code
    let userAction = getchar()
    " Convert to string
    let userAction = nr2char(userAction)
    " Close menu window
    call s:CloseMenu()
    " Retrieve command and execute it
    call s:ExecCommand(userAction)

endfunction


" Read g:leaderMenu/s:menuLevel and fill the menu's buffer
function! s:FillMenu()

    " Create the buffer used along the menu
    " Delete first if exists
    if exists('s:menuBuffer')
        unlet s:menuBuffer
    endif

    " Convert the conf into a list of string and create/fill the buffer
    call s:CreateMenuString()
    let s:menuBuffer = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:menuBuffer, 0, 0, 0, s:menuList)

endfunction


" Parse g:leaderMenu and create a list of string to display
function! s:CreateMenuString()

    let title = ""
    let s:menuList = []

    " First add the different user configuration
    for [key, val] in items(g:leaderMenu)
        if key != "name"
            " Extract description (ix 0 = cmd, ix 1 = description)
            " and add a space margin
            let str = " [". key . "] " . val[1]
            call add(s:menuList, str)
        endif
    endfor

    " Put in shape the menu
    call s:DoMenuLayout()

    " Then parse the menu to search for a name
    for [key, val] in items(g:leaderMenu)
        if key == "name" && !empty(val)
            let title = val
        endif
    endfor

    " If title doesn't exist, simply name it 'Menu'
    if empty(title)
        let title = " Leader Key Menu:"
    endif

    " Append as first element the menu title and a blank on last line
    let s:menuList = [title, ""] + s:menuList + [""]

endfunction


" Used to create the final layout of the menu,
" by arranging the entry over the full window space
function! s:DoMenuLayout()

    " Sort list with alphabetic order and ignore case
    let layout = sort(s:menuList, "i")
    " Get max len of menu items
    let lenMax = s:GetLongestLine(s:menuList)
    " Compute window width abnd item per line
    let winLen = (&columns * g:leaderMapperWidth / 100)
    let maxItem = winLen / lenMax
    let maxItemLen = float2nr(ceil(winLen / maxItem))

    " Recreate the final layout based on maximum item per row
    let s:menuList = [" ╭" . repeat("─", (maxItem * maxItemLen) + 1) . "╮"]
    let tempItem = " │ "

    let iLen = 0
    " Concatenate the items to display several by line as
    " long it fits into the window
    for item in layout
        " Get numbver of space to append
        let itemLen = len(item)
        let missingLen = maxItemLen - itemLen
        " Append whitespace to have equal length entries
        let newItem = item .repeat(" ", missingLen)
        let tempItem = tempItem . newItem
        " If matched the num of item per line, append and continue
        let iLen += 1
        if iLen == maxItem
            let tempItem = tempItem . "│"
            call add(s:menuList, tempItem)
            let tempItem = " │ "
            let iLen = 0
        endif

    endfor

    let bot = " ╰" . repeat("─", (maxItem * maxItemLen) + 1) . "╯"
    call add(s:menuList, bot)

endfunction


" Execute command requested by user
function! s:ExecCommand(cmd)

    " Check first the command exists in dict
    if !has_key(g:leaderMenu, a:cmd)
        return
    endif

    " Extract command (ix 0 = cmd, ix 1 = description)
    let cmd = get(g:leaderMenu, a:cmd)[0]
    " Finally run the command
    execute cmd

endfunction


" Restore compatible mode
let &cpo = s:save_cpo
unlet s:save_cpo
