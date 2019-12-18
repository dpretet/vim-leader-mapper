if exists("b:current_syntax")
    finish
endif

syntax keyword leaderMapperKeyword Open Close select open close
highlight link leaderMapperKeyword Keyword

" syn region LeaderMapperKeys start="\["hs=e+1 end="\]\s"he=s-1
            " \ contained
" syn region LeaderMapperBrackets start="\(^\|\s\+\)\[" end="\]\s\+"
            " \ contains=LeaderMapperKeys keepend
" syn region LeaderMapperDesc start="^" end="$"
            " \ contains=LeaderMapperBrackets
" 
" hi def link LeaderMapperDesc Identifier
" hi def link LeaderMapperKeys Type
" hi def link LeaderMapperBrackets Delimiter

let b:current_syntax = "leaderMapper"
