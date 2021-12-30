#!/bin/bash

# Install Applications
function runSection {
  promptNewSection "APPLICATIONS"
  if [[ $REPLY =~ ^[Yy]$ ]]; then

    if isMacOs; then
      # Can only install brew apps if brew is installed
      if cmdExists brew; then
        # Install Caffeine
        caskInstallAppPrompt "Caffeine.app" "caffeine"
        # Install Sip Color Picker
        caskInstallAppPrompt "Sip.app" "sip"
        # Install Flux
        caskInstallAppPrompt "Flux.app" "flux"
        # Install Postman
        caskInstallAppPrompt "Postman.app" "postman"
        # Install Spotify
        caskInstallAppPrompt "Spotify.app" "spotify"
        # Install Slack
        caskInstallAppPrompt "Slack.app" "slack"
        # Install VirtualBox
        caskInstallAppPrompt "VirtualBox.app" "virtualbox"
        # Install Firefox
        caskInstallAppPrompt "Firefox.app" "firefox"
        # Install Gimp
        caskInstallAppPrompt "Gimp.app" "gimp"
        # Install Docker
        caskInstallAppPrompt "Docker.app" "docker" configureDocker
        # Preserve white space by changing the Internal Field Separator
        IFS='%'
        # Install and configure Chrome
        caskInstallAppPrompt "Google Chrome.app" "google-chrome"
        # Reset the Internal Field Separator
        unset IFS

        # Install applications that need configuring
        # Install Rectangle
        caskInstallAppPrompt "Rectangle.app" "rectangle" configureRectangle
        # Install Visual Studio Code
        caskInstallAppPrompt "Visual Studio Code.app" "visual-studio-code" configureVSCode
        # Install and configure iTerm2
        caskInstallAppPrompt "iTerm.app" "iterm2" configureITerm

        # Cleanup downloads
        info "Cleaning up application .zip and .dmg files"
        brew cleanup
      else
        fail "Failed to install Applications via Homebrew Cask. Homebrew is not installed."
      fi
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
