" ~/.vimrc - Vim configuration

" ----- General -----
set nocompatible              " Use Vim settings, not Vi
set encoding=utf-8            " UTF-8 encoding
set fileencoding=utf-8
set history=1000              " Command history
set undolevels=1000           " Undo history
set autoread                  " Auto reload changed files
set hidden                    " Allow hidden buffers

" ----- Appearance -----
syntax enable                 " Syntax highlighting
set number                    " Line numbers
set relativenumber            " Relative line numbers
set cursorline                " Highlight current line
set showmatch                 " Highlight matching brackets
set wrap                      " Wrap long lines
set linebreak                 " Wrap at word boundaries
set scrolloff=8               " Keep 8 lines above/below cursor
set sidescrolloff=8           " Keep 8 columns left/right of cursor
set signcolumn=yes            " Always show sign column
set colorcolumn=80,120        " Show column guides
set laststatus=2              " Always show status line
set showcmd                   " Show partial commands
set showmode                  " Show current mode
set title                     " Set terminal title

" ----- Colors -----
set background=dark
set termguicolors             " True color support (if terminal supports it)

" ----- Indentation -----
set autoindent                " Copy indent from current line
set smartindent               " Smart autoindenting
set expandtab                 " Spaces instead of tabs
set tabstop=2                 " Tab = 2 spaces
set shiftwidth=2              " Indent = 2 spaces
set softtabstop=2             " Backspace deletes 2 spaces
set smarttab                  " Smart tab handling

" ----- Search -----
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results
set ignorecase                " Case insensitive search
set smartcase                 " Unless uppercase is used

" ----- Backups -----
set nobackup                  " No backup files
set noswapfile                " No swap files
set nowritebackup             " No backup before overwriting

" ----- Performance -----
set lazyredraw                " Don't redraw during macros
set ttyfast                   " Faster terminal connection

" ----- Splits -----
set splitbelow                " Open horizontal splits below
set splitright                " Open vertical splits right

" ----- Completion -----
set wildmenu                  " Command line completion
set wildmode=longest:list,full
set wildignore+=*.o,*.obj,*.pyc,*.class
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set wildignore+=*/node_modules/*,*/vendor/*

" ----- Key Mappings -----

" Leader key
let mapleader = " "           " Space as leader key

" Quick save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Clear search highlight
nnoremap <leader>h :nohlsearch<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize splits with arrows
nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Stay in visual mode when indenting
vnoremap < <gv
vnoremap > >gv

" Quick escape
inoremap jk <Esc>
inoremap kj <Esc>

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Copy to system clipboard
vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y

" Paste from system clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" ----- File Type Settings -----
autocmd FileType python setlocal tabstop=4 shiftwidth=4
autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab
autocmd FileType make setlocal noexpandtab

" ----- Strip trailing whitespace on save -----
autocmd BufWritePre * :%s/\s\+$//e

" ----- Remember cursor position -----
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   execute "normal! g`\"" |
  \ endif
