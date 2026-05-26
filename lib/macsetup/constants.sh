#!/bin/bash

################################
# Constants For Install Script #
################################

macsetupAnsiCode() {
  if [ -n "${TERM:-}" ] && [ "${TERM:-}" != "dumb" ]; then
    printf '\033[%sm' "$1"
  fi
}

macsetupTerminalCode() {
  local ansi_code="$1"
  shift

  local tput_code=""
  if [ -n "${TERM:-}" ] && [ "${TERM:-}" != "dumb" ] && command -v tput >/dev/null 2>&1; then
    tput_code="$(tput "$@" 2>/dev/null || true)"
  fi

  if [ -n "$tput_code" ]; then
    printf '%s' "$tput_code"
  else
    macsetupAnsiCode "$ansi_code"
  fi
}

# FONT COLORS
RED="$(macsetupTerminalCode "91" setaf 9)"
ORANGE="$(macsetupTerminalCode "38;5;172" setaf 172)"
GREEN="$(macsetupTerminalCode "32" setaf 2)"
BLUE="$(macsetupTerminalCode "94" setaf 12)"
YELLOW="$(macsetupTerminalCode "93" setaf 11)"
GRAY="$(macsetupTerminalCode "90" setaf 8)"
LIGHT_GRAY="$(macsetupTerminalCode "37" setaf 7)"
HEADER_BLUE="$(macsetupAnsiCode "38;2;194;203;237")"
BOLD="$(macsetupTerminalCode "1" bold)"
DIM="$(macsetupTerminalCode "2" dim)"
RESET_COLOR="$(macsetupTerminalCode "0" sgr0)"

UI_BOX_COLOR="${DIM}${LIGHT_GRAY}"
UI_TITLE_COLOR="${BOLD}${HEADER_BLUE}"
UI_FOOTER_COLOR="$UI_BOX_COLOR"
UI_SELECTED_COLOR="$BOLD"

# Root folder
ROOT_MAC_SETUP_FOLDER=~/.mac_setup
# Where to store the execution log
LOG_PATH=$ROOT_MAC_SETUP_FOLDER/log
# The directory to store file and folder backups (i.e. dot file backups)
BACKUP_DIRECTORY=$ROOT_MAC_SETUP_FOLDER/backups

# Repository layout
MACSETUP_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
MACSETUP_LIB_DIR="$MACSETUP_ROOT/lib/macsetup"
MACSETUP_CONFIG_DIR="$MACSETUP_ROOT/config"
MACSETUP_ASSETS_DIR="$MACSETUP_ROOT/assets"
