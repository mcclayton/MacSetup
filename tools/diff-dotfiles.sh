#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

repo_root="$(scriptDirectory)/.."

# Bring in constants
source "$repo_root/lib/macsetup/constants.sh"
# Bring in helper functions and managed config inventory
source "$MACSETUP_LIB_DIR/helperFunctions.sh"
# Bring in config diff helpers
source "$MACSETUP_LIB_DIR/configDiff.sh"

macsetupFindDotFileChanges
result="$?"

if [ "$result" -eq 0 ]; then
  success "Managed dotfiles match current machine files."
else
  warn "Managed dotfile drift detected."
fi

exit "$result"
