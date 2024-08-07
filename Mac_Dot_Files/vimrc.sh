"UTF-8 Support
set encoding=utf-8

"Enable line numbering
set number

"Always show the status line
set laststatus=2

"Set the number of undos allowed
set undolevels=1000

"Backspace will delete over end of line and indent characters and can delete previously modified text.
set backspace=indent,eol,start

"Start scrolling when 8 lines away from margins
set scrolloff=8

"Mouse support
set mouse=a


"Show current cursor position
set ruler

"Restore cursor to last cursor line position on file re-open
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"Load in vim bundles using pathogen
call pathogen#infect()
call pathogen#helptags()

"Enable airline powerline fonts
let g:airline_powerline_fonts = 1

"Display the status line always
set laststatus=2

"""""""""""""""""""""""""
" Colors + Highlighting "
"""""""""""""""""""""""""
"256 Color Support
set t_Co=256

"Syntax Highlighting
filetype on
filetype plugin on
syntax on

"Set the colorscheme to vividchalk (Must be in the '~/.vim/colors/' directory
colorscheme vividchalk

"Use colors optimized for dark background
set background=dark

"Set the coloring of the line numbers
highlight LineNr cterm=bold ctermfg=24 ctermbg=NONE

"Highlight the current line
set cursorline
highlight CursorLine cterm=bold ctermbg=18
highlight CursorLineNR cterm=bold ctermfg=17 ctermbg=190

"Reset highlighting on exit
au VimLeave * hi clear


"""""""""""""""""""""""
" Whitespace Settings "
"""""""""""""""""""""""
"Enables Autoindent
set autoindent
"Use spaces instead of tab characters
set expandtab
"Helps with backspacing because of expand tab
set smarttab
"Number of spaces to use per tab
set softtabstop=4
"Number of spaces to use for autoindent
set shiftwidth=4
"Round indent to a multiple of shiftwidth
set shiftround


"""""""""""""
" VertSplit "
"""""""""""""
"Disable highlighting vertical split bar in vim
highlight VertSplit ctermbg=NONE
highlight VertSplit ctermfg=24
highlight VertSplit cterm=NONE

"Make the vertical split bar a solid line
set fillchars=vert:\│


""""""""""""
" NERDTree "
""""""""""""
"Auto open Nerdtree
au VimEnter * NERDTree

"Automatically close vim if NERDTree is the only window remaining
autocmd bufenter * if (winnr("$") == 1 && &filetype == 'nerdtree') | q | endif

"Keep focus on the file when opening vim with a file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() > 0 || exists('s:std_in') | wincmd p | endif


""""""""""""""""
" Key Mappings "
""""""""""""""""
"Ctrl+g to toggle GitGutter
map <C-g> :GitGutterToggle<CR>

"Ctrl+n to toggle nerdtree
map <C-n> :NERDTreeToggle<CR>

"Map Ctrl+t to open fzf Fuzzy File Finding
map <C-T> :FZF<cr>
