"---------------------------------------------------------------
" Plugin:      https://github.com/damofthemoon/vim-leader-mapper
" Description: A plugin to create a leader key menu
" Maintainer:  Damien Pretet https://github.com/damofthemoon
"---------------------------------------------------------------

if exists('loaded_leader_mapper_vim') || &cp
    finish
endif

let loaded_leader_mapper_vim = 1

" Next initialize the variable if not specified by user

if !has('g:leaderMapperPos')
    " Can be center, NW, SW, NE, SE
    let g:leaderMapperPos = "center"
endif

if !has('g:leaderMapperWidth')
    " Percentage of the window
    let g:leaderMapperWidth = 50
endif

if !has('g:leaderMapperHeight')
    " Percentage of the window
    let g:leaderMapperHeight = 50
endif

" Save compatible mode
let s:save_cpo = &cpo
" Reset compatible mode to default value
set cpo&vim

" Declare startup command
command! -nargs=0 StartLeaderMapper call leaderMapper#start()

" Restore compatible mode
let &cpo = s:save_cpo
unlet s:save_cpo
