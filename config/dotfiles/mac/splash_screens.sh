terminalColumns() {
  local columns=""

  if command -v tput >/dev/null 2>&1; then
    columns="$(tput cols 2>/dev/null || true)"
  fi

  if [ -n "$columns" ]; then
    printf '%s\n' "$columns"
  else
    printf '%s\n' "${COLUMNS:-80}"
  fi
}

wolf() {
  IFS='' read -r -d '' WOLF <<'EOF'
                               __
                             .d$$b
                           .' TO$;\
                          /  : TP._;
                         / _.;  :Tb|
                        /   /   ;j$j
                    _.-"       d$$$$
                  .' ..       d$$$$;
                 /  /P'      d$$$$P. |\
                /   "      .d$$$P' |\^"l
              .'           `T$P^"""""  :
          ._.'      _.'                ;
       `-.-".-'-' ._.       _.-"    .-"
     `.-" _____  ._              .-"
    -(.g$$$$$$$b.              .'     __ _  ________
      ""^^T$$$P^)            .(:     /  ' \/ __/ __/___
        _/  -"  /.'         /:/;    / /_/_/\__/\______/
     ._.'-'`-'  ")/         /;/;   /_/ Michael Clayton
  `-.-"..--""   " /         /  ;
 .-" ..--""        -'          :
 ..--""--.-"         (\      .-(\
   ..--""              `-\(\/;`
     _.                      :
                             ;`-
                            :\
                            ;
EOF
  rainbowtext "$WOLF" -S 35
  # Print a horizontal divider
  local columns
  local horizontal_row
  columns="$(terminalColumns)"
  horizontal_row="$(printf '%*s\n' "$columns" '' | tr ' ' ─)"
  if [ "$columns" -gt 200 ]; then
    rainbowtext "$horizontal_row" -S 48 -p 10.0
  else
    rainbowtext "$horizontal_row" -S 48 -p 7.0
  fi
}

party_horse() {
  IFS='' read -r -d '' PARTY_HORSE <<'EOF'
                      .
                     /|
                    /_|
               ,   /__|
              / \,,___:'|
           ,{{| /}}}}/_.'
          }}}}` '{{'  '.
        {{{{{    _   ;, \
     ,}}}}}}    /o`\  ` ;)
    {{{{{{   /           (
    }}}}}}   |            \       _______________________
    {{{{{{{{   \            \    /    __ _  ________     \
   }}}}}}}}}   '.__      _  |   /    /  ' \/ __/ __/___   |
   {{{{{{{{       /`._  (_\ /  <    / /_/_/\__/\______/   |
    }}}}}}'      |    //___/    \  /_/ Michael Clayton    |
    `{{{{`       |     '--'      \_______________________/
     }}}'

EOF
  rainbowtext "$PARTY_HORSE"
}

mcc() {
  IFS='' read -r -d '' MCC <<'EOF'
   __ _  ________
  /  ' \/ __/ __/___
 / /_/_/\__/\______/
/_/ Michael Clayton

EOF
  # Only print graphical logo if we have all the means to display it properly
  if cmdExists viu && [ -f ~/mcc_logo.png ] && [[ $TERM_PROGRAM == "iTerm.app" ]]; then
    viu ~/mcc_logo.png -h 7
  else
    rainbowtext "$MCC"
  fi
}

charizard() {
  IFS='' read -r -d '' CHARIZARD <<'EOF'
                        ⢀⠖⡄
                 ⡤⢤⡀    ⢸ ⢱
                 ⠳⡀⠈⠢⡀  ⢀ ⠈⡄        ⡔⠦⡀
            ⢀⡤⠊⡹  ⠘⢄ ⠈⠲⢖⠈  ⠱⡀       ⠙⣄⠈⠢⣀
         ⢀⡠⠖⠁⢠⠞    ⠘⡄       ⢱        ⠈⡆  ⠉⠑⠢⢄⣀
       ⡠⠚⠁   ⡇     ⢀⠇ ⡤⡀   ⢀⣼         ⡇⢠⣾⣿⣷⣶⣤⣄⣉⠑⣄
     ⢀⠞⢁⣴⣾⣿⣿⡆⢇     ⠸⡀ ⠂⠿⢦⡰  ⠋⡄       ⢰⠁⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⢆
    ⡴⢁⣴⣿⣿⣿⣿⣿⣿⡘⡄     ⠱⣔⠤⡀     ⠈⡆      ⡜⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⢣
   ⡼⢠⣾⣿⣿⣿⣿⣿⣿⣿⣧⡘⢆     ⢃⠑⢌⣦ ⠩⠉ ⡜      ⢠⠃⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣣⡀
  ⢰⢃⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠱⡀   ⢸  ⠓⠭⡭⠙⠋       ⡜⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡱⡄
  ⡏⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⢃   ⢸    ⢰       ⢀⠜⢁⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠘⣆
 ⢸⢱⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡘⣆  ⡆    ⠘⡄    ⡠⠖⣡⣾⠁⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢸
 ⡏⣾⣿⣿⣿⣿⡿⡛⢟⢿⣿⣿⣿⣿⣿⣿⣧⡈⢦⣠⠃     ⢱⣀⠤⠒⢉⣾⡉⠻⠋⠈⢘⢿⣿⣿⣿⣿⠿⣿⣿⠏⠉⠻⢿⣿⣿⣿⣿⡘⡆
⢰⡇⣿⣿⠟⠁⢸⣠⠂⡄⣃⠜⣿⣿⠿⠿⣿⣿⡿⠦⡎     ⠒⠉⠉⠑⣴⣿⣿⣎⠁⠠⠂⠮⢔⣿⡿⠉⠁ ⠹⡛⢀⣀⡠ ⠙⢿⣿⣿⡇⡇
⠘⡇⠏   ⡾⠤⡀⠑⠒⠈⠣⣀⣀⡀⠤⠋⢀⡜⣀⣠⣤⣀      ⠙⢿⡟⠉⡃⠈⢀⠴⣿⣿⣀⡀   ⠈⡈⠊    ⠙⢿⡇⡇
 ⠿    ⠈ ⠉⠙⠓⢤⣀ ⠁⣀⡠⢔⡿⠊    ⠙⢦⡀ ⠐⠢⢄⡀⠁⡲⠃ ⡜ ⠹⠟⠻⣿⣰⡐⣄⠎        ⢣⡇
            ⠈⠉⠉⠁ ⡜        ⠱⡀   ⠙⢦⣀⢀⡴⠁    ⠉⠁⢱⠈⢆
                ⢰⠁         ⢱    ⠈⢏⠉         ⡇⠈⡆
               ⡠⣿           ⡇     ⠱⡄        ⡇ ⢸
             ⢀⡜ ⢹           ⢸      ⠘⣆      ⣰⠃  ⡇
             ⡾  ⠘⣆          ⠸⠁      ⠸⡄   ⢀⡴⠁  ⢀⠇   __ _  ________
             ⢧   ⠘⢆         ⡇        ⣧⣠⠤⠖⠋    ⡸   /  ' \/ __/ __/___
             ⠈⠢⡀   ⠳⢄       ⢣        ⡏      ⢀⡴⠁  / /_/_/\__/\______/
            ⣀⡠⠊⠈⠁   ⡔⠛⠲⣤⣀⣀⣀ ⠈⢣⡀     ⢸⠁   ⢀⡠⢔⠝   /_/ Michael Clayton
          ⠐⢈⠤⠒⣀    ⣀⠟   ⠑⠢⢄⡀  ⠈⡗⠂   ⠙⢦⠤⠒⢊⡡⠚⠁
           ⠆⠒⣒⡁⠬⠦⠒⠉        ⠈⠉⠒⢺⢠⠤⡀⢀⠤⡀⠠⠷⡊⠁
                              ⠘⠣⡀⡱⠧⡀⢰⠓⠤⡁
                                ⠈⠁ ⠈⠃
EOF
  rainbowtext "$CHARIZARD" -S 35
  # Print a horizontal divider
  local columns
  local horizontal_row
  columns="$(terminalColumns)"
  horizontal_row="$(printf '%*s\n' "$columns" '' | tr ' ' ─)"
  if [ "$columns" -gt 200 ]; then
    rainbowtext "$horizontal_row" -S 48 -p 10.0
  else
    rainbowtext "$horizontal_row" -S 48 -p 7.0
  fi
}
