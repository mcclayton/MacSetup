#!/bin/bash

################################
# Constants For Install Script #
################################

# FONT COLORS
RED=$(tput setaf 9)
ORANGE=$(tput setaf 172)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 12)
YELLOW=$(tput setaf 11)
GRAY=$(tput setaf 8)
LIGHT_GRAY=$(tput setaf 7)
HEADER_BLUE=$'\033[38;2;194;203;237m'
BOLD=$(tput bold)
DIM=$(tput dim)
RESET_COLOR=$(tput sgr0)

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
