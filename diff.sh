#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

# Bring in constants
source "$(scriptDirectory)/installation/constants.sh"
# Bring in the helper functions
source "$(scriptDirectory)/installation/helperFunctions.sh"
# Bring in the application configuration util
source "$(scriptDirectory)/installation/appConfigUtil.sh"

function diff {
  if cmdExists delta; then
    delta "$@"
  elif cmdExists git; then
    git diff "$@"
  else
    # Invoke original command
    command diff "$@"
  fi
}

# Diff dot files in Mac Setup against current machine files
# to detect missing files and differences.
find_dot_file_changes() {
  topLevelDotFiles=(
    "bashrc"
    "bash_profile"
    "profile"
    "zshrc"
    "zprofile"
    "utility_aliases"
    "config_vars"
    "splash_screens"
  )

  filesToDiff=()
  for dotFileName in "${topLevelDotFiles[@]}"; do
    LOCAL_FILE=~/."$dotFileName"
    if [ ! -f $LOCAL_FILE ]; then
      warn "Dotfile $dotFileName is not present on current machine."
    else
      filesToDiff+=($dotFileName)
    fi
  done

  for dotFileName in "${filesToDiff[@]}"; do
    LOCAL_FILE=~/."$dotFileName"
    SETUP_FILE="$(scriptDirectory)"/Mac_Dot_Files/"$dotFileName".sh
    diff $SETUP_FILE $LOCAL_FILE
  done
}

find_dot_file_changes
