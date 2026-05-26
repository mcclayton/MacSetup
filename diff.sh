#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

# Bring in constants
source "$(scriptDirectory)/lib/macsetup/constants.sh"
# Bring in the helper functions
source "$(scriptDirectory)/lib/macsetup/helperFunctions.sh"
# Bring in the application configuration util
source "$(scriptDirectory)/lib/macsetup/appConfigUtil.sh"

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

diff_managed_file() {
  local setup_file="$1"
  local local_file="$2"
  local label="$3"

  if [ ! -f "$setup_file" ]; then
    warn "Managed file $setup_file is not present in MacSetup."
  elif [ ! -f "$local_file" ]; then
    warn "$label is not present on current machine."
  else
    diff "$setup_file" "$local_file"
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
    "tmux.conf"
  )

  for dotFileName in "${topLevelDotFiles[@]}"; do
    diff_managed_file \
      "$MACSETUP_CONFIG_DIR/dotfiles/mac/$dotFileName.sh" \
      "$HOME/.$dotFileName" \
      "Dotfile .$dotFileName"
  done
}

find_config_file_changes() {
  diff_managed_file \
    "$MACSETUP_CONFIG_DIR/asdf/tool-versions" \
    "$HOME/.tool-versions" \
    "asdf tool versions"

  diff_managed_file \
    "$MACSETUP_CONFIG_DIR/terminal/ghostty/config" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config" \
    "Ghostty config"
}

find_dot_file_changes
find_config_file_changes
