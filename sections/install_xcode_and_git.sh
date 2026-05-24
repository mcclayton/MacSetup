#!/bin/bash

# Set up Xcode command line tools
function runSection {
  runPromptedSection "XCODE COMMAND LINE TOOLS + GIT" installXcodeAndGit
}

installXcodeAndGit() {
  if isMacOs; then
    info "Installing Xcode Command Line Tools"
    xcode-select --install
    # Test to ensure successful install
    assertPackageInstallation gcc "Xcode CLT"
    assertPackageInstallation git "Git"
  else
    warn "This is a MacOS specific step, skipping due to invalid OS..."
  fi
}
