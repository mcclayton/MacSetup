#!/bin/bash

####################
# Helper Functions #
####################

# Compatibility entrypoint for shared framework helpers. Keep this file sourced
# by callers, while implementation lives in focused modules.
source "$MACSETUP_LIB_DIR/ui.sh"
source "$MACSETUP_LIB_DIR/logging.sh"
source "$MACSETUP_LIB_DIR/platform.sh"
source "$MACSETUP_LIB_DIR/dotfiles.sh"
source "$MACSETUP_LIB_DIR/sectionRegistry.sh"
source "$MACSETUP_LIB_DIR/prompts.sh"
source "$MACSETUP_LIB_DIR/backup.sh"
source "$MACSETUP_LIB_DIR/assertions.sh"
source "$MACSETUP_LIB_DIR/installers.sh"
