# vim leader-mapper

# Introduction

Vim-Leader-Mapper is a Neovim plugin to create leader key mapping and a visual menu to display them.
It's basically a copy of Spacemacs interactive menu, relying on leader key to toggle it.

- Easy to use: the user can simply add his own commands with few setup and map them to leader key.
- Configurable: the user can associate any command (internal or external command).
- Fast: the plugin is very small, written in pure vimL.
- No intrusion: no change on user mapping & configuration.

It's also inspired from [vim-leader-guide](github.com/hecal3/vim-leader-guide) but simpler and using
floating window to display leader menu.


# Installation

[Use Vim-Plug](https://github.com/junegunn/vim-plug) or any other plugin manager to install it.

```vim
    Plug 'damofthemoon/vim-leader-mapper'
```

Follows a configuration example, binding regular Vim commands and FZF:

````vim

" Define the menu content with a Vim dictionary
let g:leaderMenu = {'name':  "",
             \'f': [":Files",                       "FZF file search"],
             \'b': [":Buffers",                     "FZF buffer search"],
             \'s': [":BLines",                      "FZF text search into current buffer"],
             \'S': [":Lines",                       "FZF text search across loaded buffers"],
             \'g': [":BCommits",                    "FZF git commits of the current buffer"],
             \'G': [":Commits",                     "FZF git commits of the repository"],
             \'v': [':vsplit',                      'Split buffer vertically'],
             \'h': [':split',                       'Split buffer horizontally'],
             \'d': [':bd',                          'Close buffer'],
             \'r': [':so $MYVIMRC',                 'Reload vimrc without restarting Vim'],
             \'l': [':ls',                          'List opened buffers'],
             \'t': [':Tags',                        'FZF tag search'],
             \'o': [':normal gf',                   'Open file under cursor'],
             \}
```

Finally to bind to bind leader key to space and toggle the menu on each space pressure:

````vim
" Define leader key to space and call vim-leader-mapper
nnoremap <Space> <Nop>
let mapleader = "\<Space>"
nnoremap <silent> <leader> :call leaderMapper#start() "<Space>"<CR>
vnoremap <silent> <leader> :call leaderMapper#start() "<Space>"<CR>
```

# TODO

- Enhance display: provide color and better render the menu (today single row)
- Support sub-menu
- Support different position on screen, today only centered
