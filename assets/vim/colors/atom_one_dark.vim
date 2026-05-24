" Vim color scheme
" Name:         atom_one_dark.vim
" Description: Atom One Dark palette matching the VS Code theme used in this setup.

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "atom_one_dark"

function! AtomOneDarkApplyColors() abort
  highlight! Normal       ctermfg=145 ctermbg=236 guifg=#ABB2BF guibg=#282C34
  highlight! Cursor       ctermfg=236 ctermbg=75 guifg=#282C34 guibg=#528BFF
  highlight! LineNr       cterm=NONE ctermfg=67 ctermbg=235 gui=NONE guifg=#636D83 guibg=#21252B
  highlight! CursorLine   cterm=NONE ctermbg=238 gui=NONE guibg=#343A46
  highlight! CursorLineNr cterm=bold ctermfg=188 ctermbg=238 gui=bold guifg=#D7DAE0 guibg=#343A46
  highlight! ColorColumn  ctermbg=235 guibg=#2C313A
  highlight! VertSplit    cterm=NONE ctermfg=238 ctermbg=235 gui=NONE guifg=#3A3F4B guibg=#21252B
  highlight! SignColumn   ctermbg=236 guibg=#282C34
  highlight! NonText      ctermfg=241 ctermbg=236 guifg=#5C6370 guibg=#282C34
  highlight! SpecialKey   ctermfg=241 guifg=#5C6370
  highlight! Directory    cterm=bold ctermfg=145 gui=bold guifg=#ABB2BF
  highlight! Search       cterm=bold ctermfg=188 ctermbg=68 gui=bold guifg=#D7DAE0 guibg=#3A4B66
  highlight! IncSearch    cterm=bold ctermfg=236 ctermbg=75 gui=bold guifg=#282C34 guibg=#528BFF
  highlight! Visual       ctermbg=238 guibg=#3E4451
  highlight! StatusLine   cterm=bold ctermfg=188 ctermbg=235 gui=bold guifg=#D7DAE0 guibg=#21252B
  highlight! StatusLineNC ctermfg=145 ctermbg=235 guifg=#9DA5B4 guibg=#21252B
  highlight! Pmenu        ctermfg=145 ctermbg=235 guifg=#ABB2BF guibg=#21252B
  highlight! PmenuSel     cterm=bold ctermfg=188 ctermbg=236 gui=bold guifg=#D7DAE0 guibg=#2C313A
  highlight! TabLine      ctermfg=145 ctermbg=235 guifg=#9DA5B4 guibg=#21252B
  highlight! TabLineSel   cterm=bold ctermfg=188 ctermbg=236 gui=bold guifg=#D7DAE0 guibg=#282C34
  highlight! TabLineFill  ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
  highlight! Comment      cterm=italic ctermfg=241 gui=italic guifg=#5C6370
  highlight! Constant     ctermfg=173 guifg=#D19A66
  highlight! Number       ctermfg=173 guifg=#D19A66
  highlight! Boolean      ctermfg=173 guifg=#D19A66
  highlight! Character    ctermfg=114 guifg=#98C379
  highlight! String       ctermfg=114 guifg=#98C379
  highlight! Identifier   ctermfg=145 guifg=#ABB2BF
  highlight! Function     ctermfg=75 guifg=#61AFEF
  highlight! Statement    cterm=bold ctermfg=176 gui=bold guifg=#C678DD
  highlight! Keyword      cterm=bold ctermfg=176 gui=bold guifg=#C678DD
  highlight! Conditional  cterm=bold ctermfg=176 gui=bold guifg=#C678DD
  highlight! Repeat       cterm=bold ctermfg=176 gui=bold guifg=#C678DD
  highlight! Operator     ctermfg=73 guifg=#56B6C2
  highlight! PreProc      ctermfg=176 guifg=#C678DD
  highlight! Type         cterm=bold ctermfg=180 gui=bold guifg=#E5C07B
  highlight! Special      ctermfg=73 guifg=#56B6C2
  highlight! Title        cterm=bold ctermfg=168 gui=bold guifg=#E06C75
  highlight! Error        cterm=bold ctermfg=188 ctermbg=167 gui=bold guifg=#D7DAE0 guibg=#E06C75
  highlight! Todo         cterm=bold ctermfg=236 ctermbg=180 gui=bold guifg=#282C34 guibg=#E5C07B

  highlight! NERDTreeDir       cterm=bold ctermfg=145 gui=bold guifg=#ABB2BF
  highlight! NERDTreeDirSlash  ctermfg=241 guifg=#5C6370
  highlight! NERDTreeFile      ctermfg=145 guifg=#ABB2BF
  highlight! NERDTreeExecFile  ctermfg=114 guifg=#98C379
  highlight! NERDTreeOpenable  cterm=bold ctermfg=75 gui=bold guifg=#528BFF
  highlight! NERDTreeClosable  cterm=bold ctermfg=75 gui=bold guifg=#528BFF
  highlight! NERDTreeCWD       cterm=bold ctermfg=188 gui=bold guifg=#D7DAE0
  highlight! NERDTreeCurrentNode cterm=bold ctermfg=188 ctermbg=238 gui=bold guifg=#D7DAE0 guibg=#343A46
  highlight! NERDTreeUp        ctermfg=241 guifg=#5C6370
  highlight! NERDTreeHelp      ctermfg=241 guifg=#5C6370

  highlight! GitGutterAdd    cterm=bold ctermfg=114 ctermbg=236 gui=bold guifg=#98C379 guibg=#282C34
  highlight! GitGutterChange cterm=bold ctermfg=173 ctermbg=236 gui=bold guifg=#D19A66 guibg=#282C34
  highlight! GitGutterDelete cterm=bold ctermfg=168 ctermbg=236 gui=bold guifg=#E06C75 guibg=#282C34

  highlight! CocErrorSign       cterm=bold ctermfg=168 ctermbg=236 gui=bold guifg=#E06C75 guibg=#282C34
  highlight! CocWarningSign     cterm=bold ctermfg=180 ctermbg=236 gui=bold guifg=#E5C07B guibg=#282C34
  highlight! CocInfoSign        cterm=bold ctermfg=75 ctermbg=236 gui=bold guifg=#61AFEF guibg=#282C34
  highlight! CocHintSign        cterm=bold ctermfg=73 ctermbg=236 gui=bold guifg=#56B6C2 guibg=#282C34
  highlight! CocErrorHighlight  cterm=underline ctermfg=168 gui=undercurl guifg=#E06C75 guisp=#E06C75
  highlight! CocWarningHighlight cterm=underline ctermfg=180 gui=undercurl guifg=#E5C07B guisp=#E5C07B
  highlight! CocInfoHighlight   cterm=underline ctermfg=75 gui=undercurl guifg=#61AFEF guisp=#61AFEF
  highlight! CocHintHighlight   cterm=underline ctermfg=73 gui=undercurl guifg=#56B6C2 guisp=#56B6C2
  highlight! CocFloating        ctermfg=145 ctermbg=235 guifg=#ABB2BF guibg=#21252B
  highlight! CocMenuSel         cterm=bold ctermfg=188 ctermbg=236 gui=bold guifg=#D7DAE0 guibg=#2C313A
  highlight! CocHighlightText   ctermbg=238 guibg=#3E4451
  highlight! CocCodeLens        ctermfg=241 guifg=#5C6370

  highlight! BuffetCurrentBuffer cterm=bold ctermbg=236 ctermfg=188 gui=bold guibg=#282C34 guifg=#D7DAE0
  highlight! BuffetActiveBuffer cterm=bold ctermbg=236 ctermfg=145 gui=bold guibg=#2C313A guifg=#ABB2BF
  highlight! BuffetBuffer cterm=NONE ctermbg=235 ctermfg=145 gui=NONE guibg=#21252B guifg=#9DA5B4
  highlight! BuffetTrunc cterm=NONE ctermbg=235 ctermfg=241 gui=NONE guibg=#21252B guifg=#5C6370
  highlight! BuffetTab cterm=bold ctermbg=75 ctermfg=188 gui=bold guibg=#528BFF guifg=#D7DAE0
  highlight! BuffetModBuffer cterm=NONE ctermbg=235 ctermfg=173 gui=NONE guibg=#21252B guifg=#D19A66
  highlight! BuffetModActiveBuffer cterm=bold ctermbg=236 ctermfg=173 gui=bold guibg=#2C313A guifg=#D19A66
  highlight! BuffetModCurrentBuffer cterm=bold ctermbg=236 ctermfg=173 gui=bold guibg=#282C34 guifg=#D19A66

  highlight! airline_a cterm=bold ctermfg=188 ctermbg=75 gui=bold guifg=#D7DAE0 guibg=#528BFF
  highlight! airline_b ctermfg=188 ctermbg=236 guifg=#D7DAE0 guibg=#2C313A
  highlight! airline_c ctermfg=145 ctermbg=235 guifg=#ABB2BF guibg=#21252B
  highlight! airline_x ctermfg=145 ctermbg=235 guifg=#ABB2BF guibg=#21252B
  highlight! airline_y ctermfg=188 ctermbg=236 guifg=#D7DAE0 guibg=#2C313A
  highlight! airline_z cterm=bold ctermfg=188 ctermbg=75 gui=bold guifg=#D7DAE0 guibg=#528BFF
  highlight! airline_a_inactive ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
  highlight! airline_b_inactive ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
  highlight! airline_c_inactive ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
  highlight! airline_x_inactive ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
  highlight! airline_y_inactive ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
  highlight! airline_z_inactive ctermfg=241 ctermbg=235 guifg=#5C6370 guibg=#21252B
endfunction

call AtomOneDarkApplyColors()
