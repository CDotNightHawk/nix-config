" i forgot what this is even for?
" let mapleader = ';'

" what is this for?
" imap <C-K> <C-X><C-O>

" i don't remember what this is for
" autocmd filetype python nnoremap ;r :term python3 %<cr>
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 autoindent
autocmd FileType php setlocal noexpandtab tabstop=4 shiftwidth=4 autoindent
autocmd FileType json setlocal expandtab tabstop=2 shiftwidth=2 autoindent
autocmd FileType nix setlocal expandtab tabstop=2 shiftwidth=2 autoindent
autocmd FileType lua setlocal expandtab tabstop=4 shiftwidth=4 autoindent
autocmd FileType c setlocal expandtab tabstop=4 shiftwidth=4 autoindent
autocmd FileType h setlocal expandtab tabstop=4 shiftwidth=4 autoindent
autocmd FileType toml setlocal expandtab tabstop=2 shiftwidth=2 autoindent
autocmd FileType markdown setlocal wrap linebreak

autocmd BufNewFile,BufRead *.plist setlocal filetype=xml
autocmd BufNewFile,BufRead *.service setlocal filetype=dosini
autocmd BufNewFile,BufRead *.ini.example setlocal filetype=dosini
autocmd BufNewFile,BufRead *.spec setlocal filetype=python
autocmd BufNewFile,BufRead *.gm9 setlocal filetype=sh
autocmd BufNewFile,BufRead Dockerfile* setlocal filetype=dockerfile
autocmd BufNewFile,BufRead *.dockerfile setlocal filetype=dockerfile
autocmd BufNewFile,BufRead *.nix setlocal filetype=nix
autocmd BufNewFile,BufRead *.deck setlocal filetype=toml

" this is placed after all the autocmds due to a bug
" https://github.com/neovim/neovim/issues/31589
syntax on
