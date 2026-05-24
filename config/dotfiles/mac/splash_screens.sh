splashTerminalColumns() {
  local terminal_columns=""

  if command -v tput >/dev/null 2>&1 && [ "${TERM:-dumb}" != "dumb" ]; then
    terminal_columns="$(tput cols 2>/dev/null || true)"
  fi

  case "$terminal_columns" in
    ''|*[!0-9]*)
      terminal_columns="${COLUMNS:-80}"
      ;;
  esac

  case "$terminal_columns" in
    ''|*[!0-9]*)
      terminal_columns=80
      ;;
  esac

  printf '%s' "$terminal_columns"
}

splashHorizontalRow() {
  local terminal_columns="$1"
  printf '%*s\n' "$terminal_columns" '' | tr ' ' ─
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
  local SPLASH_COLUMNS
  local HORIZONTAL_ROW
  SPLASH_COLUMNS="$(splashTerminalColumns)"
  HORIZONTAL_ROW="$(splashHorizontalRow "$SPLASH_COLUMNS")"
  if [ "$SPLASH_COLUMNS" -gt 200 ]; then
    rainbowtext "$HORIZONTAL_ROW" -S 48 -p 10.0
  else
    rainbowtext "$HORIZONTAL_ROW" -S 48 -p 7.0
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
  if cmdExists viu && [ -f ~/mcc_logo.png ] && [[ ${TERM_PROGRAM:-} == "iTerm.app" ]]; then
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
  local SPLASH_COLUMNS
  local HORIZONTAL_ROW
  SPLASH_COLUMNS="$(splashTerminalColumns)"
  HORIZONTAL_ROW="$(splashHorizontalRow "$SPLASH_COLUMNS")"
  if [ "$SPLASH_COLUMNS" -gt 200 ]; then
    rainbowtext "$HORIZONTAL_ROW" -S 48 -p 10.0
  else
    rainbowtext "$HORIZONTAL_ROW" -S 48 -p 7.0
  fi
}
