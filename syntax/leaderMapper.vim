if exists("b:current_syntax")
    finish
endif

syntax case ignore
syntax keyword leaderMapperKeyword select open close write read fzf load git
                                   \ buffer buffers search tag terminal execute
                                   \ task item image link column table row status
                                   \ rows columns tag tags
highlight link leaderMapperKeyword Keyword

syn region LeaderMapperKeys start="\["hs=e+1 end="\]\s"he=s-1 contained
syn region LeaderMapperBrackets start="\(^\|\s\+\)\[" end="\]\s\+" contains=leaderMapperKeyword keepend

hi def link LeaderMapperKeys Type
hi def link LeaderMapperBrackets Delimiter

let b:current_syntax = "leaderMapper"
