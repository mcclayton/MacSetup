#!/bin/bash

# Set up fonts
function runSection {
  promptNewSection "SETTING UP FONTS"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      info "Opening Inconsolata-g.otf font"
      open "$(scriptDirectory)/fonts/Inconsolata-g.otf"
      manualAction "Press Install Font Button for Inconsolata-g.otf"

      info "Opening Powerline Inconsolata-g font"
      open "$(scriptDirectory)/fonts/Inconsolata-g for Powerline.otf"
      manualAction "Press Install Font Button for Inconsolata-g for Powerline.otf"

      info "Opening Inconsolata Nerd Font Icons.otf"
      open "$(scriptDirectory)/fonts/Inconsolata Nerd Font Icons.otf"
      manualAction "Press Install Font Button for Inconsolata Nerd Font Icons.otf"
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
