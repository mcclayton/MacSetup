#!/bin/bash

#######################
# Installer Functions #
#######################

brewPackageInstalled() {
  brew list --formula --versions "$1" > /dev/null 2>&1
}

installHomebrewPackage() {
  local display_name="$1"
  local formula="$2"
  local assertion_command="$3"
  local configure_function="${4:-}"
  local tap="${5:-}"

  info "Installing Package: $display_name"

  if brewPackageInstalled "$formula"; then
    info "$display_name is already installed"
  else
    if [ -n "$tap" ] && ! brew tap "$tap"; then
      fail "Failed to tap Homebrew repository: $tap"
      return 1
    fi

    if ! brew install "$formula"; then
      fail "Failed to install Homebrew package: $display_name"
      return 1
    fi
  fi

  if [ -n "$configure_function" ]; then
    "$configure_function"
  fi

  if [ -n "$assertion_command" ]; then
    assertPackageInstallation "$assertion_command" "$display_name"
  fi
}

installHomebrewPackagesFromList() {
  local package_entry=""
  local display_name=""
  local formula=""
  local assertion_command=""
  local configure_function=""
  local tap=""

  for package_entry in "$@"; do
    IFS='|' read -r display_name formula assertion_command configure_function tap <<< "$package_entry"
    installHomebrewPackage "$display_name" "$formula" "$assertion_command" "$configure_function" "$tap"
  done
}

caskInstallAppsFromList() {
  local app_entry=""
  local app_name=""
  local cask_name=""
  local configure_function=""

  for app_entry in "$@"; do
    IFS='|' read -r app_name cask_name configure_function <<< "$app_entry"
    caskInstallAppPrompt "$app_name" "$cask_name" "$configure_function"
  done
}

caskInstallAppPrompt() {
  local app_name="$1"
  local cask_name="$2"
  local configure_function="${3:-}"

  promptYesNo "Install application $app_name?"

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Installing Application: $app_name"
    if brew ls --cask --versions "$cask_name" > /dev/null 2>&1; then
      warn "$app_name is already installed. Prompting overwrite..."
      promptYesNo "Do you want to $RED OVERWRITE $RESET_COLOR application $app_name?"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "/Applications/$app_name"
        brew reinstall --cask "$cask_name"
        if [ -n "$configure_function" ]; then
          "$configure_function"
        fi
      else
        info "Skipping overwrite..."
      fi
    else
      brew install --cask "$cask_name"
      if [ -n "$configure_function" ]; then
        "$configure_function"
      fi
    fi
    assertAppInstallation "$app_name"
  else
    info "Skipping Installation..."
  fi
}
