#!/bin/bash

# Install Applications
function runSection {
  runPromptedSection "APPLICATIONS" installApplications
}

installApplications() {
  if isMacOs; then
    # Can only install brew apps if brew is installed
    if cmdExists brew; then
      local applications=(
        "Caffeine.app|caffeine|"
        "Sip.app|sip|"
        "Flux.app|flux|"
        "Postman.app|postman|"
        "Spotify.app|spotify|"
        "Beekeeper Studio.app|beekeeper-studio|"
        "Slack.app|slack|"
        "VirtualBox.app|virtualbox|"
        "Firefox.app|firefox|"
        "Gimp.app|gimp|"
        "Docker.app|docker|configureDocker"
        "Google Chrome.app|google-chrome|"
        "Rectangle.app|rectangle|configureRectangle"
        "Visual Studio Code.app|visual-studio-code|configureVSCode"
        "iTerm.app|iterm2|configureITerm"
      )

      caskInstallAppsFromList "${applications[@]}"

      # Cleanup downloads
      info "Cleaning up application .zip and .dmg files"
      brew cleanup
    else
      fail "Failed to install Applications via Homebrew Cask. Homebrew is not installed."
    fi
  else
    warn "This is a MacOS specific step, skipping due to invalid OS..."
  fi
}
