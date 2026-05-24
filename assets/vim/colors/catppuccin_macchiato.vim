" Vim color scheme
" Name:         catppuccin_macchiato.vim
" Description: Catppuccin Macchiato palette tuned for Ghostty, FZF, Coc, and Vim UI.

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "catppuccin_macchiato"

function! CatppuccinMacchiatoApplyColors() abort
  highlight! Normal       ctermfg=189 ctermbg=235 guifg=#CAD3F5 guibg=#24273A
  highlight! Cursor       ctermfg=234 ctermbg=224 guifg=#181926 guibg=#F4DBD6
  highlight! LineNr       cterm=NONE ctermfg=60 ctermbg=234 gui=NONE guifg=#6E738D guibg=#1E2030
  highlight! CursorLine   cterm=NONE ctermbg=237 gui=NONE guibg=#363A4F
  highlight! CursorLineNr cterm=bold ctermfg=222 ctermbg=237 gui=bold guifg=#EED49F guibg=#363A4F
  highlight! ColorColumn  ctermbg=237 guibg=#363A4F
  highlight! VertSplit    cterm=NONE ctermfg=60 ctermbg=234 gui=NONE guifg=#494D64 guibg=#1E2030
  highlight! SignColumn   ctermbg=235 guibg=#24273A
  highlight! NonText      ctermfg=60 ctermbg=235 guifg=#6E738D guibg=#24273A
  highlight! SpecialKey   ctermfg=60 guifg=#6E738D
  highlight! Directory    cterm=bold ctermfg=111 gui=bold guifg=#8AADF4
  highlight! Search       cterm=bold ctermfg=234 ctermbg=222 gui=bold guifg=#181926 guibg=#EED49F
  highlight! IncSearch    cterm=bold ctermfg=234 ctermbg=216 gui=bold guifg=#181926 guibg=#F5A97F
  highlight! Visual       ctermbg=60 guibg=#494D64
  highlight! StatusLine   cterm=bold ctermfg=189 ctermbg=234 gui=bold guifg=#CAD3F5 guibg=#1E2030
  highlight! StatusLineNC ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! Pmenu        ctermfg=189 ctermbg=234 guifg=#CAD3F5 guibg=#1E2030
  highlight! PmenuSel     cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#181926 guibg=#C6A0F6
  highlight! PmenuSbar    ctermbg=234 guibg=#1E2030
  highlight! PmenuThumb   ctermbg=60 guibg=#5B6078
  highlight! PmenuKind    ctermfg=111 ctermbg=234 guifg=#8AADF4 guibg=#1E2030
  highlight! PmenuKindSel cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#181926 guibg=#C6A0F6
  highlight! PmenuExtra   ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! PmenuExtraSel ctermfg=234 ctermbg=183 guifg=#181926 guibg=#C6A0F6
  highlight! NormalFloat  ctermfg=189 ctermbg=234 guifg=#CAD3F5 guibg=#1E2030
  highlight! FloatBorder  ctermfg=60 ctermbg=234 guifg=#5B6078 guibg=#1E2030
  highlight! TabLine      ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! TabLineSel   cterm=bold ctermfg=189 ctermbg=235 gui=bold guifg=#CAD3F5 guibg=#24273A
  highlight! TabLineFill  ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! WildMenu     cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#181926 guibg=#C6A0F6
  highlight! Folded       ctermfg=60 ctermbg=234 guifg=#A5ADCB guibg=#1E2030
  highlight! FoldColumn   ctermfg=60 ctermbg=235 guifg=#6E738D guibg=#24273A
  highlight! MatchParen   cterm=bold ctermfg=234 ctermbg=116 gui=bold guifg=#181926 guibg=#8BD5CA
  highlight! QuickFixLine cterm=bold ctermfg=189 ctermbg=60 gui=bold guifg=#CAD3F5 guibg=#494D64
  highlight! Comment      cterm=italic ctermfg=60 gui=italic guifg=#6E738D
  highlight! Constant     ctermfg=216 guifg=#F5A97F
  highlight! Number       ctermfg=216 guifg=#F5A97F
  highlight! Boolean      ctermfg=216 guifg=#F5A97F
  highlight! Character    ctermfg=150 guifg=#A6DA95
  highlight! String       ctermfg=150 guifg=#A6DA95
  highlight! Identifier   ctermfg=189 guifg=#CAD3F5
  highlight! Function     ctermfg=111 guifg=#8AADF4
  highlight! Statement    cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! Keyword      cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! Conditional  cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! Repeat       cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! Operator     ctermfg=183 guifg=#C6A0F6
  highlight! PreProc      ctermfg=218 guifg=#F5BDE6
  highlight! Type         cterm=bold ctermfg=222 gui=bold guifg=#EED49F
  highlight! Special      ctermfg=116 guifg=#8BD5CA
  highlight! Title        cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! Error        cterm=bold ctermfg=189 ctermbg=210 gui=bold guifg=#CAD3F5 guibg=#ED8796
  highlight! Todo         cterm=bold ctermfg=234 ctermbg=222 gui=bold guifg=#181926 guibg=#EED49F
  highlight! WarningMsg   cterm=bold ctermfg=216 gui=bold guifg=#F5A97F
  highlight! Question     cterm=bold ctermfg=150 gui=bold guifg=#A6DA95
  highlight! MoreMsg      cterm=bold ctermfg=150 gui=bold guifg=#A6DA95
  highlight! ModeMsg      cterm=bold ctermfg=111 gui=bold guifg=#8AADF4
  highlight! Conceal      ctermfg=60 ctermbg=NONE guifg=#6E738D guibg=NONE

  highlight! DiffAdd      ctermfg=150 ctermbg=22 guifg=#A6DA95 guibg=#283E37
  highlight! DiffChange   ctermfg=216 ctermbg=58 guifg=#F5A97F guibg=#463B37
  highlight! DiffDelete   ctermfg=210 ctermbg=52 guifg=#ED8796 guibg=#44313B
  highlight! DiffText     cterm=bold ctermfg=234 ctermbg=222 gui=bold guifg=#181926 guibg=#EED49F
  highlight! diffAdded    ctermfg=150 guifg=#A6DA95
  highlight! diffChanged  ctermfg=216 guifg=#F5A97F
  highlight! diffRemoved  ctermfg=210 guifg=#ED8796

  highlight! NERDTreeDir       cterm=bold ctermfg=111 gui=bold guifg=#8AADF4
  highlight! NERDTreeDirSlash  ctermfg=60 guifg=#6E738D
  highlight! NERDTreeFile      ctermfg=189 guifg=#CAD3F5
  highlight! NERDTreeExecFile  ctermfg=150 guifg=#A6DA95
  highlight! NERDTreeOpenable  cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! NERDTreeClosable  cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! NERDTreeCWD       cterm=bold ctermfg=222 gui=bold guifg=#EED49F
  highlight! NERDTreeCurrentNode cterm=bold ctermfg=189 ctermbg=60 gui=bold guifg=#CAD3F5 guibg=#494D64
  highlight! NERDTreeUp        ctermfg=60 guifg=#6E738D
  highlight! NERDTreeHelp      ctermfg=60 guifg=#6E738D
  highlight! NERDTreeHelpKey   cterm=bold ctermfg=111 gui=bold guifg=#8AADF4
  highlight! NERDTreeHelpCommand ctermfg=150 guifg=#A6DA95
  highlight! NERDTreeHelpTitle cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! NERDTreeFlags     ctermfg=216 guifg=#F5A97F
  highlight! NERDTreeLinkTarget ctermfg=60 guifg=#A5ADCB
  highlight! NERDTreeLinkFile  ctermfg=189 guifg=#CAD3F5
  highlight! NERDTreeLinkDir   cterm=bold ctermfg=111 gui=bold guifg=#8AADF4
  highlight! NERDTreeBookmarkName cterm=bold ctermfg=183 gui=bold guifg=#C6A0F6
  highlight! NERDTreeBookmarksHeader cterm=bold ctermfg=150 gui=bold guifg=#A6DA95
  highlight! NERDTreeBookmarksLeader ctermfg=150 guifg=#A6DA95
  highlight! NERDTreeBookmark ctermfg=189 guifg=#CAD3F5

  highlight! GitGutterAdd    cterm=bold ctermfg=150 ctermbg=235 gui=bold guifg=#A6DA95 guibg=#24273A
  highlight! GitGutterChange cterm=bold ctermfg=216 ctermbg=235 gui=bold guifg=#F5A97F guibg=#24273A
  highlight! GitGutterDelete cterm=bold ctermfg=210 ctermbg=235 gui=bold guifg=#ED8796 guibg=#24273A
  highlight! GitGutterChangeDelete cterm=bold ctermfg=216 ctermbg=235 gui=bold guifg=#F5A97F guibg=#24273A
  highlight! GitGutterAddLine ctermbg=22 guibg=#283E37
  highlight! GitGutterChangeLine ctermbg=58 guibg=#463B37
  highlight! GitGutterDeleteLine ctermbg=52 guibg=#44313B
  highlight! GitGutterChangeDeleteLine ctermbg=58 guibg=#463B37
  highlight! GitGutterAddIntraLine cterm=bold ctermfg=150 ctermbg=22 gui=bold guifg=#A6DA95 guibg=#283E37
  highlight! GitGutterDeleteIntraLine cterm=bold ctermfg=210 ctermbg=52 gui=bold guifg=#ED8796 guibg=#44313B
  highlight! CadenceGitLensBlame cterm=italic ctermfg=60 gui=italic guifg=#6E738D

  highlight! CocErrorSign       cterm=bold ctermfg=210 ctermbg=235 gui=bold guifg=#ED8796 guibg=#24273A
  highlight! CocWarningSign     cterm=bold ctermfg=222 ctermbg=235 gui=bold guifg=#EED49F guibg=#24273A
  highlight! CocInfoSign        cterm=bold ctermfg=111 ctermbg=235 gui=bold guifg=#8AADF4 guibg=#24273A
  highlight! CocHintSign        cterm=bold ctermfg=116 ctermbg=235 gui=bold guifg=#8BD5CA guibg=#24273A
  highlight! CocErrorHighlight  cterm=underline ctermfg=210 gui=undercurl guifg=#ED8796 guisp=#ED8796
  highlight! CocWarningHighlight cterm=underline ctermfg=222 gui=undercurl guifg=#EED49F guisp=#EED49F
  highlight! CocInfoHighlight   cterm=underline ctermfg=111 gui=undercurl guifg=#8AADF4 guisp=#8AADF4
  highlight! CocHintHighlight   cterm=underline ctermfg=116 gui=undercurl guifg=#8BD5CA guisp=#8BD5CA
  highlight! CocFloating        ctermfg=189 ctermbg=234 guifg=#CAD3F5 guibg=#1E2030
  highlight! CocMenuSel         cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#181926 guibg=#C6A0F6
  highlight! CocHighlightText   ctermbg=60 guibg=#494D64
  highlight! CocCodeLens        ctermfg=60 guifg=#6E738D
  highlight! CocFloatBorder     ctermfg=60 ctermbg=234 guifg=#5B6078 guibg=#1E2030
  highlight! CocFloatThumb      ctermbg=60 guibg=#5B6078
  highlight! CocFloatSbar       ctermbg=234 guibg=#1E2030
  highlight! CocListLine        ctermfg=189 ctermbg=60 guifg=#CAD3F5 guibg=#494D64
  highlight! CocListSearch      cterm=bold ctermfg=216 gui=bold guifg=#F5A97F
  highlight! CocSearch          cterm=bold ctermfg=216 gui=bold guifg=#F5A97F
  highlight! CocSelectedText    cterm=bold ctermfg=216 gui=bold guifg=#F5A97F
  highlight! CocListMode        cterm=bold ctermfg=150 gui=bold guifg=#A6DA95
  highlight! CocListPath        ctermfg=60 guifg=#6E738D
  highlight! CocPumSearch       cterm=bold ctermfg=216 gui=bold guifg=#F5A97F
  highlight! CocPumMenu         ctermfg=60 guifg=#6E738D
  highlight! CocPumDetail       ctermfg=60 guifg=#6E738D
  highlight! CocPumShortcut     ctermfg=222 guifg=#EED49F
  highlight! CocVirtualText     ctermfg=60 guifg=#6E738D
  highlight! CocInlayHint       ctermfg=60 ctermbg=235 guifg=#6E738D guibg=#24273A
  highlight! CocNotificationProgress cterm=bold ctermfg=150 gui=bold guifg=#A6DA95
  highlight! CocNotificationButton cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#181926 guibg=#C6A0F6
  highlight! CocNotificationKey ctermfg=222 guifg=#EED49F
  highlight! CocMarkdownLink    ctermfg=111 guifg=#8AADF4
  highlight! CocDisabled        ctermfg=60 guifg=#6E738D
  highlight! CocSymbolDefault   ctermfg=189 guifg=#CAD3F5
  highlight! CocTreeTitle       cterm=bold ctermfg=111 gui=bold guifg=#8AADF4
  highlight! CocTreeDescription ctermfg=60 guifg=#6E738D
  highlight! CocTreeSelected    ctermfg=189 ctermbg=60 guifg=#CAD3F5 guibg=#494D64

  highlight! BuffetCurrentBuffer cterm=bold ctermbg=183 ctermfg=234 gui=bold guibg=#C6A0F6 guifg=#181926
  highlight! BuffetActiveBuffer cterm=bold ctermbg=60 ctermfg=189 gui=bold guibg=#5B6078 guifg=#CAD3F5
  highlight! BuffetBuffer cterm=NONE ctermbg=234 ctermfg=60 gui=NONE guibg=#1E2030 guifg=#6E738D
  highlight! BuffetTrunc cterm=NONE ctermbg=234 ctermfg=60 gui=NONE guibg=#1E2030 guifg=#6E738D
  highlight! BuffetTab cterm=bold ctermbg=111 ctermfg=234 gui=bold guibg=#8AADF4 guifg=#181926
  highlight! BuffetModBuffer cterm=NONE ctermbg=234 ctermfg=216 gui=NONE guibg=#1E2030 guifg=#F5A97F
  highlight! BuffetModActiveBuffer cterm=bold ctermbg=60 ctermfg=189 gui=bold guibg=#5B6078 guifg=#CAD3F5
  highlight! BuffetModCurrentBuffer cterm=bold ctermbg=183 ctermfg=234 gui=bold guibg=#C6A0F6 guifg=#181926

  highlight! CadenceSearchCount cterm=bold ctermfg=150 gui=bold guifg=#A6DA95
  highlight! CadenceSearchNoMatch cterm=bold ctermfg=210 gui=bold guifg=#ED8796
  highlight! AnzuMatchline ctermfg=222 ctermbg=60 guifg=#EED49F guibg=#494D64
  highlight! webdevicons ctermfg=111 guifg=#8AADF4
  highlight! webdevicons_file_format ctermfg=222 guifg=#EED49F
  highlight! IndentLine ctermfg=237 guifg=#363A4F

  highlight! CadenceMinimapBase ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! CadenceMinimapCursor cterm=bold ctermfg=111 ctermbg=60 gui=bold guifg=#8AADF4 guibg=#494D64
  highlight! CadenceMinimapRange ctermfg=60 ctermbg=234 guifg=#A5ADCB guibg=#1E2030
  highlight! CadenceMinimapSearch cterm=bold ctermfg=216 ctermbg=58 gui=bold guifg=#F5A97F guibg=#463B37
  highlight! CadenceMinimapDiffRemoved ctermfg=210 guifg=#ED8796
  highlight! CadenceMinimapDiffAdded ctermfg=150 guifg=#A6DA95
  highlight! CadenceMinimapDiffLine ctermfg=216 guifg=#F5A97F
  highlight! CadenceMinimapCursorDiffRemoved cterm=bold ctermfg=210 ctermbg=60 gui=bold guifg=#ED8796 guibg=#494D64
  highlight! CadenceMinimapCursorDiffAdded cterm=bold ctermfg=150 ctermbg=60 gui=bold guifg=#A6DA95 guibg=#494D64
  highlight! CadenceMinimapCursorDiffLine cterm=bold ctermfg=216 ctermbg=60 gui=bold guifg=#F5A97F guibg=#494D64
  highlight! CadenceMinimapRangeDiffRemoved ctermfg=210 ctermbg=234 guifg=#ED8796 guibg=#1E2030
  highlight! CadenceMinimapRangeDiffAdded ctermfg=150 ctermbg=234 guifg=#A6DA95 guibg=#1E2030
  highlight! CadenceMinimapRangeDiffLine ctermfg=216 ctermbg=234 guifg=#F5A97F guibg=#1E2030

  highlight! airline_a cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#181926 guibg=#C6A0F6
  highlight! airline_b ctermfg=189 ctermbg=60 guifg=#CAD3F5 guibg=#5B6078
  highlight! airline_c ctermfg=189 ctermbg=234 guifg=#CAD3F5 guibg=#1E2030
  highlight! airline_x ctermfg=189 ctermbg=234 guifg=#CAD3F5 guibg=#1E2030
  highlight! airline_y ctermfg=234 ctermbg=111 guifg=#181926 guibg=#8AADF4
  highlight! airline_z cterm=bold ctermfg=234 ctermbg=222 gui=bold guifg=#181926 guibg=#EED49F
  highlight! airline_a_inactive ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! airline_b_inactive ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! airline_c_inactive ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! airline_x_inactive ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! airline_y_inactive ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
  highlight! airline_z_inactive ctermfg=60 ctermbg=234 guifg=#6E738D guibg=#1E2030
endfunction

call CatppuccinMacchiatoApplyColors()
