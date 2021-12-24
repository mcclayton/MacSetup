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
RESET_COLOR=$(tput sgr0)

# Root folder
ROOT_MAC_SETUP_FOLDER=~/.mac_setup
# Where to store the execution log
LOG_PATH=$ROOT_MAC_SETUP_FOLDER/log
# The directory to store file and folder backups (i.e. dot file backups)
BACKUP_DIRECTORY=$ROOT_MAC_SETUP_FOLDER/backups
