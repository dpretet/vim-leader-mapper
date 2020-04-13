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
    " Can be center, top, bottom
    let g:leaderMapperPos = "center"
endif

if !has('g:leaderMapperWidth')
    " Percentage of the window
    let g:leaderMapperWidth = 70
endif

" Enable debug prints in :messages
let g:leaderMapperDebug = 0

" Shared variable with commands/functions to describe visual selection
let g:leaderMapperLineStart = -1
let g:leaderMapperLineEnd = -1

" Save compatible mode
let s:save_cpo = &cpo
" Reset compatible mode to default value
set cpo&vim

" Declare startup command
command! -nargs=? -range LeaderMapper call leaderMapper#start(<line1>,<line2>)

" Restore compatible mode
let &cpo = s:save_cpo
unlet s:save_cpo
