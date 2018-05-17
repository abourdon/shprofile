#!/usr/bin/env bash
#
# Example of a simple vim (https://www.vim.org/) initialization process

# Define the .vimrc content (Adapt to your need)
cat > $HOME/.vimrc << EOL
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set background=dark

set cursorline
hi CursorLine cterm=NONE ctermbg=237

syntax on
filetype plugin indent on
EOL