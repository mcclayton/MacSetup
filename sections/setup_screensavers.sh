#!/bin/bash

# Set up screensavers
function runSection {
  promptNewSection "SETTING UP SCREENSAVERS"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      info "Opening Aerial.saver"
      open "$(scriptDirectory)/screensavers/Aerial.saver"
      manualAction "Follow MacOSX prompts to install Aerial.saver"
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
