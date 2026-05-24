#!/bin/bash

# Set up screensavers
function runSection {
  runPromptedSection "SETTING UP SCREENSAVERS" setupScreensavers
}

setupScreensavers() {
  if isMacOs; then
    info "Opening Aerial.saver"
    open "$MACSETUP_ASSETS_DIR/screensavers/Aerial.saver"
    manualAction "Follow MacOSX prompts to install Aerial.saver"
  else
    warn "This is a MacOS specific step, skipping due to invalid OS..."
  fi
}
