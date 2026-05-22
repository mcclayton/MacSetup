" Atom One Dark airline theme.

let g:airline#themes#atom_one_dark#palette = {}

let s:blue = '#528BFF'
let s:accent_blue = '#528BFF'
let s:bg = '#282C34'
let s:bg_dark = '#21252B'
let s:bg_light = '#2C313A'
let s:border = '#3A3F4B'
let s:fg = '#ABB2BF'
let s:fg_bright = '#D7DAE0'
let s:comment = '#5C6370'
let s:green = '#98C379'
let s:yellow = '#E5C07B'
let s:orange = '#D19A66'
let s:red = '#E06C75'

let s:normal_a = [s:fg_bright, s:blue, 188, 75, 'bold']
let s:normal_b = [s:fg_bright, s:bg_light, 188, 236, '']
let s:normal_c = [s:fg, s:bg_dark, 145, 235, '']
let g:airline#themes#atom_one_dark#palette.normal =
      \ airline#themes#generate_color_map(s:normal_a, s:normal_b, s:normal_c)
let g:airline#themes#atom_one_dark#palette.normal_modified = {
      \ 'airline_c': [s:orange, s:bg_dark, 173, 235, ''],
      \ }

let s:insert_a = [s:bg, s:green, 236, 114, 'bold']
let s:insert_b = [s:fg_bright, s:bg_light, 188, 236, '']
let s:insert_c = [s:fg, s:bg_dark, 145, 235, '']
let g:airline#themes#atom_one_dark#palette.insert =
      \ airline#themes#generate_color_map(s:insert_a, s:insert_b, s:insert_c)
let g:airline#themes#atom_one_dark#palette.insert_modified =
      \ g:airline#themes#atom_one_dark#palette.normal_modified

let s:visual_a = [s:bg, s:yellow, 236, 180, 'bold']
let s:visual_b = [s:fg_bright, s:bg_light, 188, 236, '']
let s:visual_c = [s:fg, s:bg_dark, 145, 235, '']
let g:airline#themes#atom_one_dark#palette.visual =
      \ airline#themes#generate_color_map(s:visual_a, s:visual_b, s:visual_c)
let g:airline#themes#atom_one_dark#palette.visual_modified =
      \ g:airline#themes#atom_one_dark#palette.normal_modified

let s:replace_a = [s:fg_bright, s:red, 188, 168, 'bold']
let s:replace_b = [s:fg_bright, s:bg_light, 188, 236, '']
let s:replace_c = [s:fg, s:bg_dark, 145, 235, '']
let g:airline#themes#atom_one_dark#palette.replace =
      \ airline#themes#generate_color_map(s:replace_a, s:replace_b, s:replace_c)
let g:airline#themes#atom_one_dark#palette.replace_modified =
      \ g:airline#themes#atom_one_dark#palette.normal_modified

let g:airline#themes#atom_one_dark#palette.terminal =
      \ g:airline#themes#atom_one_dark#palette.insert

let s:inactive_a = [s:comment, s:bg_dark, 241, 235, '']
let s:inactive_b = [s:comment, s:bg_dark, 241, 235, '']
let s:inactive_c = [s:comment, s:bg_dark, 241, 235, '']
let g:airline#themes#atom_one_dark#palette.inactive =
      \ airline#themes#generate_color_map(s:inactive_a, s:inactive_b, s:inactive_c)
let g:airline#themes#atom_one_dark#palette.inactive_modified = {
      \ 'airline_c': [s:orange, s:bg_dark, 173, 235, ''],
      \ }

let s:commandline_a = [s:fg_bright, s:accent_blue, 188, 75, 'bold']
let s:commandline_b = [s:fg_bright, s:bg_light, 188, 236, '']
let s:commandline_c = [s:fg, s:bg_dark, 145, 235, '']
let g:airline#themes#atom_one_dark#palette.commandline =
      \ airline#themes#generate_color_map(s:commandline_a, s:commandline_b, s:commandline_c)

let g:airline#themes#atom_one_dark#palette.accents = {
      \ 'red': [s:red, '', 168, ''],
      \ 'green': [s:green, '', 114, ''],
      \ 'yellow': [s:yellow, '', 180, ''],
      \ 'blue': [s:accent_blue, '', 75, ''],
      \ }
