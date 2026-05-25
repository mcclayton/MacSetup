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

pathContainsEntry() {
  local path_entry="$1"
  local old_ifs="$IFS"
  local part=""

  IFS=:
  for part in $PATH; do
    if [ "$part" = "$path_entry" ]; then
      IFS="$old_ifs"
      return 0
    fi
  done
  IFS="$old_ifs"

  return 1
}

prependPathEntry() {
  local path_entry="$1"

  if [ -z "$path_entry" ]; then
    return 0
  fi

  if ! pathContainsEntry "$path_entry"; then
    PATH="$path_entry${PATH:+:$PATH}"
    export PATH
  fi
}

prependPathEntries() {
  local path_entries=("$@")
  local index=""

  for (( index=${#path_entries[@]} - 1; index >= 0; index-- )); do
    prependPathEntry "${path_entries[$index]}"
  done
}

appendPathEntry() {
  local path_entry="$1"

  if [ -z "$path_entry" ]; then
    return 0
  fi

  if ! pathContainsEntry "$path_entry"; then
    PATH="${PATH:+$PATH:}$path_entry"
    export PATH
  fi
}

pathPrependShellLine() {
  local path_entry="$1"

  printf 'case ":$PATH:" in *":%s:"*) ;; *) export PATH="%s:$PATH" ;; esac\n' "$path_entry" "$path_entry"
}

pathAppendShellLine() {
  local path_entry="$1"

  printf 'case ":$PATH:" in *":%s:"*) ;; *) export PATH="$PATH:%s" ;; esac\n' "$path_entry" "$path_entry"
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
