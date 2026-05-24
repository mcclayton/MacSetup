#!/bin/bash

####################
# Prompt Functions #
####################

promptYesNo() {
  local default_answer="${2:-no}"

  if [ "$default_answer" = "yes" ]; then
    MACSETUP_UI_DEFAULT_INDEX=1
  else
    MACSETUP_UI_DEFAULT_INDEX=0
  fi

  chooseOption "$1" "No" "Yes"
  unset MACSETUP_UI_DEFAULT_INDEX

  if [ "$MACSETUP_UI_CHOICE" = "Yes" ]; then
    REPLY="y"
  else
    REPLY="n"
  fi
}

prompt() {
  IFS= read -r -p "   => $1 "
  unset IFS
  echo
}

finish() {
  echo
  IFS='' read -r -d '' FINISH_MESSAGE <<'EOF'
 ___ ___ _  _ ___ ___ _  _ ___ ___
| __|_ _| \| |_ _/ __| || | __|   \
| _| | || .` || |\__ \ __ | _|| |) |
|_| |___|_|\_|___|___/_||_|___|___/
EOF

  printInRainbow "$FINISH_MESSAGE"
  echo
  echo -e "$GRAY INSTALLATION COMPLETE.$RESET_COLOR"
  echo -e "$GRAY (May need to open new shell to experience all changes.)$RESET_COLOR"
  echo

  generateLog

  if [ "${#FAILURES_ARRAY[@]}" -eq 0 ]; then
    success "No failures occurred during install"
  else
    warn "The following failures occurred during install"
    printFailures
  fi

  echo
  info "View Summary Log: $LOG_PATH"

  echo
  promptYesNo "Would you like to open a new shell to experience the new changes?"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    exec "$(currShell)"
  fi
  exit 0
}

printIntro() {
  echo
  IFS='' read -r -d '' INSTALL_MESSAGE <<'EOF'
 _____           _        _ _
|_   _|         | |      | | |
  | |  _ __  ___| |_ __ _| | |
  | | | '_ \/ __| __/ _` | | |
 _| |_| | | \__ \ || (_| | | |
|_____|_| |_|___/\__\__,_|_|_|
EOF
  printInRainbow "$INSTALL_MESSAGE"
  sandboxIntro
  echo
}

sandboxIntro() {
  if [ "$SANDBOX" = true ] ; then
    echo
    echo "✨ Running In [SANDBOX] Mode ✨"
    echo "    | Changes made from script will not persist and"
    echo "    | are made in a dockerized sandbox environment."
    echo "    | Note: Not all steps are available in sandbox."
  fi
}

promptNewSection() {
  echo
  TITLE="[=== $1 ===]"
  logEntry "$TITLE"

  if ! uiIsInteractive; then
    echo "$ORANGE$TITLE $RESET_COLOR"
  fi

  MACSETUP_UI_TITLE="$1"
  if [ -n "${MACSETUP_SECTION_INDEX:-}" ] && [ -n "${MACSETUP_SECTION_TOTAL:-}" ]; then
    MACSETUP_UI_FOOTER="Section ${MACSETUP_SECTION_INDEX}/${MACSETUP_SECTION_TOTAL}"
  fi

  promptYesNo "Proceed with section?"

  unset MACSETUP_UI_TITLE
  unset MACSETUP_UI_FOOTER
}

runPromptedSection() {
  local title="$1"
  local section_function="$2"

  promptNewSection "$title"

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$section_function"
  else
    info "Skipping..."
  fi
}

manualAction() {
  echo -e "[MANUAL ACTION REQUIRED]: $1"
  read -r -p "   => Press Enter To Continue:"
}

printInRainbow() {
  if cmdExists lolcat; then
    printf "%s" "$1" | lolcat
  else
    printf "%s" "$1"
  fi
}
