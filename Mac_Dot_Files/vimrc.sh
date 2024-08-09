""""""""""""""""""""
" General Settings "
""""""""""""""""""""
"UTF-8 Support
set encoding=utf-8

"Enable line numbering
set number

"Always show the status line
set laststatus=2

"Set the number of undos allowed
set undolevels=1000

"Start scrolling when 8 lines away from margins
set scrolloff=8

"Mouse support
set mouse=a

"Show current cursor position
set ruler

"Prevents Vim from redrawing the screen while executing macros, registers, or other complex commands
set lazyredraw

"Restore cursor to last cursor line position on file re-open
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"Load in vim bundles using pathogen
call pathogen#infect()
call pathogen#helptags()

"Enable airline powerline fonts
let g:airline_powerline_fonts = 1

"""""""""""""""""""""""""
" Colors + Highlighting "
"""""""""""""""""""""""""
"256 Color Support
set t_Co=256

"Automatically detect the best regex engine to use
"Note: Do this before syntax highlighting is enabled or vim will slow down
set regexpengine=0

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


"""""""""""""""""""""""""""""""""""""
" Whitespace / Indentation Settings "
"""""""""""""""""""""""""""""""""""""
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
"Backspace will delete over end of line and indent characters and can delete previously modified text.
set backspace=indent,eol,start
" Indentation visualization via indentline plugin
let g:indentLine_char_list = ['︴']
let g:indentLine_enabled = 1


"""""""
" FZF "
"""""""
function! FzfWithPreview()
  if system('git rev-parse --is-inside-work-tree 2>/dev/null') ==# "true\n"
    let l:source = 'git ls-files --others --exclude-standard --cached --directory --full-name --no-empty-directory'
  else
    let l:source = 'find . -type f'
  endif

  call fzf#run(fzf#wrap({
  \ 'source': l:source,
  \ 'sink': 'e',
  \ 'options': '--preview ''bat --style=numbers --color=always {}'' --bind shift-up:preview-page-up,shift-down:preview-page-down'
  \ }))
endfunction


"""""""""""""
" VertSplit "
"""""""""""""
"Disable highlighting vertical split bar in vim
highlight VertSplit ctermbg=NONE
highlight VertSplit ctermfg=24
highlight VertSplit cterm=NONE

"Make the vertical split bar a solid line
set fillchars=vert:\│


"""""""""""""""""""""""""""
" Vim Buffer/Window Hooks "
"""""""""""""""""""""""""""
"Checks if only windows open are utility windows (i.e. NERDTree, minimap)
function! AllWindowsAreUtility() abort
  " Loop through all windows
  for win in range(1, winnr('$'))
      " Check the filetype of the window
      let filetype = getbufvar(winbufnr(win), '&filetype')
      if filetype != 'nerdtree' && filetype != 'minimap'
          return 0
      endif
  endfor
  return 1
endfunction
"Automatically close vim if only window(s) remaining are utility windows
autocmd! BufEnter * if AllWindowsAreUtility() | call timer_start(0, { -> execute('quit') }) | endif

" Ensure buffet uses devicons (Needs to be done on VimEnter once all plugins are loaded)
autocmd! VimEnter * let g:buffet_use_devicons = 1
"Auto open Nerdtree
autocmd VimEnter * NERDTree

"Keep focus on the file when opening vim with a file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() > 0 || exists('s:std_in') | wincmd p | endif


""""""""""""""""
" Tabbed Files "
""""""""""""""""
let g:buffet_powerline_separators = 1
let g:buffet_always_show_tabline = 1
function! g:BuffetSetCustomColors()
  hi! BuffetCurrentBuffer cterm=bold ctermbg=24 ctermfg=190 guibg=#000000 guifg=#00FF00
  hi! BuffetActiveBuffer cterm=bold ctermbg=NONE ctermfg=190 guibg=#000000 guifg=#00FF00
  hi! BuffetBuffer cterm=NONE ctermbg=NONE ctermfg=17 guibg=#000000 guifg=#00FF00
  hi! BuffetTrunc cterm=NONE ctermbg=NONE ctermfg=17 guibg=#000000 guifg=#00FF00
  hi! BuffetTab cterm=bold ctermbg=190 ctermfg=17 guibg=#000000 guifg=#00FF00
  hi! BuffetTrunc cterm=NONE ctermbg=NONE ctermfg=17 guibg=#000000 guifg=#00FF00
  hi! BuffetModBuffer cterm=NONE ctermbg=NONE ctermfg=17 guibg=#000000 guifg=#00FF00
  hi! BuffetModActiveBuffer cterm=bold ctermbg=NONE ctermfg=17 guibg=#000000 guifg=#00FF00
  hi! BuffetModCurrentBuffer cterm=bold ctermbg=NONE ctermfg=17 guibg=#000000 guifg=#00FF00
endfunction
let g:buffet_tab_icon = '⸬ tabs ⸬'
let g:buffet_use_devicons = 1

"""""""""""
" Minimap "
"""""""""""
let g:minimap_width = 10
let g:minimap_auto_start = 1


"""""""""""""""
" Git Plugins "
"""""""""""""""
"Configure GitGutter
highlight GitGutterAdd    ctermfg=2 ctermbg=NONE cterm=bold
highlight GitGutterChange ctermfg=24 ctermbg=NONE cterm=bold
highlight GitGutterDelete ctermfg=1 ctermbg=NONE cterm=bold
highlight SignColumn guibg=NONE ctermbg=NONE
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_removed = '┃'
let g:gitgutter_sign_removed_first_line = '┃'
let g:gitgutter_sign_removed_above_and_below = '┃'
let g:gitgutter_sign_modified_removed = '┃'
let g:gitgutter_sign_untracked = '┃'
let g:gitgutter_sign_ignored = '┃'
"Use low update time instead of realtime
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0
set updatetime=250

"Configure GitLens
let g:GIT_LENS_CONFIG = {
    \ 'blame_wrap': v:false,
    \ 'blame_empty_line': v:false,
    \ 'blame_delay': 800
    \ }
"Default GitGutter and GitLens to be enabled
let g:GIT_LENS_ENABLED = 1
let g:gitgutter_enabled = 1


""""""""""""""""
" Key Mappings "
""""""""""""""""
"Ctrl+d to close many plugins proviging a more minimal experience
map <C-d> :MinimapClose<CR>:NERDTreeClose<CR>:GitGutterDisable<CR>

"Ctrl+m to toggle code minimap
map <C-m> :MinimapToggle<CR>

"Ctrl+g to toggle GitGutter and GitLens
map <C-g> :GitGutterToggle<CR>:call ToggleGitLens()<CR>

"Ctrl+n to toggle nerdtree
map <C-n> :NERDTreeToggle<CR>

"Map Ctrl+t to open fzf Fuzzy File Finding with preview
map <C-T> :call FzfWithPreview()<CR>

"Map Tab to navigate to next tab (using buffet plugin)
noremap <Tab> :bn<CR>
"Map Shift+Tab to navigate to previous tab (using buffet plugin)
noremap <S-Tab> :bp<CR>
"Map \ + Tab to close current tab (using buffet plugin)
noremap <Leader><Tab> :Bw<CR>

"Note: Ctrl+ww to switch between windows (i.e. Nerdtree and file)"
