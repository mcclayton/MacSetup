#!/bin/bash

# Set new top-level dot files
function runSection {
promptNewSection "SETTING UP TOP-LEVEL DOT FILES"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    topLevelDotFiles=(
      "bashrc"
      "bash_profile"
      "profile"
      "zshrc"
      "zprofile"
      "utility_aliases"
      "config_vars"
    )

    info "Backing up top-level dot files"

    # Backup Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
      backupFile ~/."$dotFileName" "$dotFileName"
    done

    info "Setting top-level dot files"

    # Set Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
      cp "$(scriptDirectory)"/Mac_Dot_Files/"$dotFileName".sh ~/."$dotFileName"
      assertFileExists ~/."$dotFileName" "~/.$dotFileName set" "Failed to set ~/.$dotFileName"
    done
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
