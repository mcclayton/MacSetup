#!/bin/bash

#######################
# Installer Functions #
#######################

installPackage() {
  info "Installing Package: $1"
  if cmdExists "$1"; then
    info "$1 is already installed"
  else
    $2
    if [ -n "$3" ]; then
      $3
    fi
  fi
}

installAsdfPlugin() {
  local plugin="$1"
  local plugin_url="${2:-}"

  if asdf plugin list 2>/dev/null | grep -Fxq "$plugin"; then
    info "asdf plugin $plugin is already installed"
    return 0
  fi

  if [ -n "$plugin_url" ]; then
    asdf plugin add "$plugin" "$plugin_url"
  else
    asdf plugin add "$plugin"
  fi
}

caskInstallAppPrompt() {
  promptYesNo "Install application $1?"

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Installing Application: $1"
    if brew ls --cask --versions "$2" > /dev/null 2>&1; then
      warn "$1 is already installed. Prompting overwrite..."
      promptYesNo "Do you want to $RED OVERWRITE $RESET_COLOR application $1?"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "/Applications/$1"
        brew reinstall --cask "$2"
        if [ -n "$3" ]; then
          $3
        fi
      else
        info "Skipping overwrite..."
      fi
    else
      brew install --cask "$2"
      if [ -n "$3" ]; then
        $3
      fi
    fi
    assertAppInstallation "$1"
  else
    info "Skipping Installation..."
  fi
}
