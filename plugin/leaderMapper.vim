"---------------------------------------------------------------
" Plugin:      https://github.com/damofthemoon/vim-leader-mapper
" Description: A plugin to create a leader key men u
" Maintainer:  Damien Pretet https://github.com/damofthemoon
"---------------------------------------------------------------

if exists('loaded_leader_mapper_vim') || &cp
    finish
endif
let loaded_leader_mapper_vim = 1

" Save compatible mode
let s:save_cpo = &cpo
" Reset compatible mode to default value
set cpo&vim


command! -nargs=0 StartLeaderMapper call leaderMapper#start()


" Restore compatible mode
let &cpo = s:save_cpo
unlet s:save_cpo
