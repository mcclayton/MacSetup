#!/bin/bash

# Set up Xcode command line tools
function runSection {
  promptNewSection "XCODE COMMAND LINE TOOLS + GIT"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      info "Installing Xcode Command Line Tools"
      xcode-select --install
      # Test to ensure successful install
      assertPackageInstallation gcc "Xcode CLT"
      assertPackageInstallation git "Git"
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
