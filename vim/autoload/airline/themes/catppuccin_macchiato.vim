" Catppuccin Macchiato airline theme.

let g:airline#themes#catppuccin_macchiato#palette = {}

let s:bg = '#24273A'
let s:bg_dark = '#1E2030'
let s:bg_light = '#363A4F'
let s:pill = '#5B6078'
let s:fg = '#CAD3F5'
let s:dark_text = '#181926'
let s:comment = '#6E738D'
let s:green = '#A6DA95'
let s:yellow = '#EED49F'
let s:peach = '#F5A97F'
let s:red = '#ED8796'
let s:blue = '#8AADF4'
let s:mauve = '#C6A0F6'

let s:normal_a = [s:dark_text, s:mauve, 234, 183, 'bold']
let s:normal_b = [s:fg, s:pill, 189, 60, '']
let s:normal_c = [s:fg, s:bg_dark, 189, 234, '']
let g:airline#themes#catppuccin_macchiato#palette.normal =
      \ airline#themes#generate_color_map(s:normal_a, s:normal_b, s:normal_c)
let g:airline#themes#catppuccin_macchiato#palette.normal_modified = {
      \ 'airline_c': [s:peach, s:bg_dark, 216, 234, ''],
      \ }

let s:insert_a = [s:dark_text, s:green, 234, 150, 'bold']
let s:insert_b = [s:fg, s:pill, 189, 60, '']
let s:insert_c = [s:fg, s:bg_dark, 189, 234, '']
let g:airline#themes#catppuccin_macchiato#palette.insert =
      \ airline#themes#generate_color_map(s:insert_a, s:insert_b, s:insert_c)
let g:airline#themes#catppuccin_macchiato#palette.insert_modified =
      \ g:airline#themes#catppuccin_macchiato#palette.normal_modified

let s:visual_a = [s:dark_text, s:yellow, 234, 222, 'bold']
let s:visual_b = [s:fg, s:pill, 189, 60, '']
let s:visual_c = [s:fg, s:bg_dark, 189, 234, '']
let g:airline#themes#catppuccin_macchiato#palette.visual =
      \ airline#themes#generate_color_map(s:visual_a, s:visual_b, s:visual_c)
let g:airline#themes#catppuccin_macchiato#palette.visual_modified =
      \ g:airline#themes#catppuccin_macchiato#palette.normal_modified

let s:replace_a = [s:dark_text, s:red, 234, 210, 'bold']
let s:replace_b = [s:fg, s:pill, 189, 60, '']
let s:replace_c = [s:fg, s:bg_dark, 189, 234, '']
let g:airline#themes#catppuccin_macchiato#palette.replace =
      \ airline#themes#generate_color_map(s:replace_a, s:replace_b, s:replace_c)
let g:airline#themes#catppuccin_macchiato#palette.replace_modified =
      \ g:airline#themes#catppuccin_macchiato#palette.normal_modified

let g:airline#themes#catppuccin_macchiato#palette.terminal =
      \ g:airline#themes#catppuccin_macchiato#palette.insert

let s:inactive_a = [s:comment, s:bg_dark, 60, 234, '']
let s:inactive_b = [s:comment, s:bg_dark, 60, 234, '']
let s:inactive_c = [s:comment, s:bg_dark, 60, 234, '']
let g:airline#themes#catppuccin_macchiato#palette.inactive =
      \ airline#themes#generate_color_map(s:inactive_a, s:inactive_b, s:inactive_c)
let g:airline#themes#catppuccin_macchiato#palette.inactive_modified = {
      \ 'airline_c': [s:peach, s:bg_dark, 216, 234, ''],
      \ }

let s:commandline_a = [s:dark_text, s:blue, 234, 111, 'bold']
let s:commandline_b = [s:fg, s:pill, 189, 60, '']
let s:commandline_c = [s:fg, s:bg_dark, 189, 234, '']
let g:airline#themes#catppuccin_macchiato#palette.commandline =
      \ airline#themes#generate_color_map(s:commandline_a, s:commandline_b, s:commandline_c)

let g:airline#themes#catppuccin_macchiato#palette.accents = {
      \ 'red': [s:red, '', 210, ''],
      \ 'green': [s:green, '', 150, ''],
      \ 'yellow': [s:yellow, '', 222, ''],
      \ 'blue': [s:blue, '', 111, ''],
      \ }
