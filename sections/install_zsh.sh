#!/bin/bash

# Install ZSH
function runSection {
  runPromptedSection "INSTALL ZSH" installZsh
}

installZsh() {
  # Can only install brew packages if brew is installed
  if cmdExists brew; then
    # Install zsh
    installPackage zsh "brew install zsh"
    assertPackageInstallation zsh "zsh"
  else
    fail "Failed to install zsh. Homebrew is required to install."
  fi
}
