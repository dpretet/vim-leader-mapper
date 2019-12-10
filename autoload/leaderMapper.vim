"---------------------------------------------------------------
" Plugin:      https://github.com/damofthemoon/vim-leader-mapper
" Description: A plugin to create a leader key men u
" Maintainer:  Damien Pretet https://github.com/damofthemoon
"---------------------------------------------------------------

" Save compatible mode
let s:save_cpo = &cpo
" Reset compatible mode to default value
set cpo&vim

" Startup function to call the plugin
function! leaderMapper#start()

    if has('nvim')
        OpenFloatingWin()
    else
        OpenPopupWin()
    endif

endfunction


" Open floating window where menu is displayed
" Neovim only
function! OpenFloatingWin()

  let height = &lines - 3
  let width = float2nr(&columns - (&columns * 2 / 10))
  let col = float2nr((&columns - width) / 2)

  "Set the position, size, etc. of the floating window.
  let opts = {
        \ 'relative': 'editor',
        \ 'row': height * 0.3,
        \ 'col': col + 30,
        \ 'width': width * 2 / 3,
        \ 'height': height / 2
        \ }

  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)

  "Set Floating Window Highlighting
  call setwinvar(win, '&winhl', 'Normal:Pmenu')
  " call setwinvar(win, '&winhl', 'NormalFloat:TabLine')

  setlocal
        \ buftype=nofile
        \ nobuflisted
        \ bufhidden=hide
        \ nonumber
        \ norelativenumber
        \ signcolumn=no
endfunction


" Open popup window where menu is displayed
" Vim only
function! OpenPopupWin()
    " TODO: Implement for Vim 8
endfunction


" Restore compatible mode
let &cpo = s:save_cpo
unlet s:save_cpo
