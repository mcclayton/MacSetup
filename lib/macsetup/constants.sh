#!/bin/bash

################################
# Constants For Install Script #
################################

# FONT COLORS
macsetupTput() {
  local term_name="${TERM:-dumb}"

  if ! command -v tput >/dev/null 2>&1 || [ "$term_name" = "dumb" ]; then
    return 0
  fi

  if tput "$@" 2>/dev/null; then
    return 0
  fi

  case "$term_name" in
    xterm-ghostty|ghostty)
      TERM=xterm-256color tput "$@" 2>/dev/null || true
      ;;
  esac
}

RED=$(macsetupTput setaf 9)
ORANGE=$(macsetupTput setaf 172)
GREEN=$(macsetupTput setaf 2)
BLUE=$(macsetupTput setaf 12)
YELLOW=$(macsetupTput setaf 11)
GRAY=$(macsetupTput setaf 8)
LIGHT_GRAY=$(macsetupTput setaf 7)
HEADER_BLUE=$'\033[38;2;194;203;237m'
BOLD=$(macsetupTput bold)
DIM=$(macsetupTput dim)
RESET_COLOR=$(macsetupTput sgr0)

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
