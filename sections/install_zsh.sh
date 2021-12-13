#!/bin/bash

# Install ZSH
function runSection {
  promptNewSection "INSTALL ZSH"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Can only install brew packages if brew is installed
    if cmdExists brew; then
      # Install zsh
      installPackage zsh "brew install zsh"
      assertPackageInstallation zsh "zsh"
    else
      fail "Failed to install zsh. Homebrew is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
