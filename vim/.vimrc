" Drop vi compatabililty
if &compatible
     set nocompatible
endif

" === Config ===

" History length
set history=700

" Theme options
colorscheme onehalflight
set background=light
set number
set scrolloff=5
set shortmess+=I
set laststatus=2

" Indent with 4 spaces
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set smarttab

" Highlight current line
" set cursorline

" Indentation
set autoindent
set smartindent
set cindent

" Disable wrapping completely
set nowrap
set textwidth=0
set wrapmargin=0

" Wrap on 'convenient' characters (only if wrapping is enabled)
" set linebreak

" Do not redraw during macro execution
set lazyredraw
set ttyfast

" Show non-printable chars
set nolist
let &listchars = "tab:>_,trail:\u00b7,extends:\u00bb,precedes:\u00ab,nbsp:\u00b7"
if &encoding ==# 'utf-8' && has('gui_running')
    let &listchars = "tab:\u21e5 ,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u00b7"
endif

" Matching bracket [{()}] highlighting
set showmatch

" Automatic indent detection
filetype plugin on
filetype indent on

" Enable mode lines
set modeline
set modelines=5

" Syntax highlighting
syntax enable

" Automatically write files e.g. when Ctrl+Z-ing
set autowrite

" Automatic reloading of externally changed files
set autoread

" Tab-completion in the command line
set wildmenu
set wildignore+=*.o,*~,*.pyc,*/.git*/,*/.hg/*,*.swp,*.toc,*.aux,*.fls,*.so,*.pyc,*/node_modules/*,*/__pycache__/*
let NERDTreeIgnore=['\.o$', '\~$', '^\.git$', '^\.hg$', '\.swp$', '\.toc$', '\.aux$', '\.fls$', '\.so$', '\.pyc$', '^node_modules', '^__pycache__$']

" Height of the command bar
set cmdheight=1

" Search behavior: if only lowercase, be case-insensitive
" otherwise, be case sensitive
set ignorecase
set smartcase

" Highlight search results
set hlsearch

" Jump to search result while typing
set incsearch
if has('nvim')
    set inccommand=nosplit
endif

" Enable regular expressions
set magic

" No bells
set noerrorbells
set novisualbell
set t_vb=
set timeoutlen=500

" Set default file encoding
set encoding=utf8

" Don't create backup files
set nobackup
set nowritebackup
" set noswapfile

" Use tabs for multiple buffers
set switchbuf=usetab,newtab

" Use the mouse
set mouse=nv
if !has('nvim')
    set ttymouse=xterm
endif

" Disable cursor styling with nvim
" https://github.com/neovim/neovim/issues/8234#issuecomment-378910263
if has('nvim')
    set guicursor=
endif

" Wrap cursor keys around end of line
set whichwrap+=<,>,h,l,[,]

" Wrap backspace also around the end of line
set backspace=indent,eol,start

" Overlength highlighting after 80 characters
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
match ErrorMsg '\s\+$'

" Restore file position
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Use selection clipboard ("unnamed") for y/p
if has('clipboard')
    set clipboard=unnamed
endif

" Highlight config files as DOS-Ini files
autocmd BufNewFile,BufRead *.cff set filetype=dosini

" Highlight markdown files as ... markdown!
autocmd BufNewFile,BufRead *.md set filetype=markdown

" Highlight VUE files as ... markdown!
autocmd BufNewFile,BufRead *.vue set filetype=vue

" Correct indentation for yaml files
autocmd BufNewFile,BufRead *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Build Go files and tests on save
augroup auto_go
    autocmd!
    autocmd BufWritePost *.go :GoFmt
    " autocmd BufWritePost *.go :GoBuild
    " autocmd BufWritePost *_test.go :GoTest
augroup end

" === Commands ===

" Write current file as root
command! SudoW w !sudo tee % >/dev/null

" Trim trailing spaces
command! TrimTrailing %s/\s\+$//e

" === Keybinds ===

nnoremap <C-Left> :tabp<CR>
nnoremap <C-Right> :tabn<CR>
noremap <C-s> :w<CR>
noremap <C-f> <C-]>

" Trim trailing spaces on 'gt' key combo
vnoremap gt :s/\s\+$//e<CR>

" Auto-completion
if has("gui_running")
    inoremap <C-Space> <C-N>
else
    inoremap <Nul> <C-N>
endif

" key to toggle PASTE mode
set pastetoggle=<F3>

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
