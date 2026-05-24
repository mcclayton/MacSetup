#!/bin/bash

# Set new top-level dot files
function runSection {
  runPromptedSection "SETTING UP TOP-LEVEL DOT FILES" setupDotFiles
}

setupDotFiles() {
  info "Backing up top-level dot files"

  # Backup Dot Files
  for dotFileName in "${MACSETUP_MANAGED_TOP_LEVEL_DOTFILES[@]}"; do
    backupFile ~/."$dotFileName" "$dotFileName"
  done

  info "Setting top-level dot files"

  # Set Dot Files
  for dotFileName in "${MACSETUP_MANAGED_TOP_LEVEL_DOTFILES[@]}"; do
    runCommand "Copy ~/.$dotFileName" cp "$MACSETUP_CONFIG_DIR"/dotfiles/mac/"$dotFileName".sh ~/."$dotFileName" || continue
    assertFileExists ~/."$dotFileName" "~/.$dotFileName set" "Failed to set ~/.$dotFileName"
  done
}
