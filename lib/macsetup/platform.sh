#!/bin/bash

######################
# Platform Functions #
######################

ensureNotRoot() {
  if [ "$EUID" -eq 0 ]; then
    warn "Please do not run entire script as root."
    info "Exiting..."
    exit
  fi
}

cmdExists() {
  [ "$#" -gt 0 ] && hash "$1" 2>/dev/null
}

currShell() {
  local curr_shell=""

  if cmdExists finger; then
    curr_shell="$(finger "$USER" | grep 'Shell:*' | cut -f3 -d ":")"
  else
    curr_shell="$(grep "^$(id -un):" /etc/passwd | cut -d : -f 7-)"
  fi

  echo "$curr_shell"
}

isMacOs() {
  local uname_out=""

  uname_out="$(uname -s)"
  case "$uname_out" in
    Darwin*)
      return 0
      ;;
  esac

  return 1
}
