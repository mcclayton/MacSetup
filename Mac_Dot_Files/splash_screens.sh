# Define an alias for a horse wearing a party hat. Why not?
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
  rainbowtext "$WOLF"
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
