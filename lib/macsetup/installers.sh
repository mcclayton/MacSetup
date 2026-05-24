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
    if [ -n "$tap" ] && ! runCommand "Tap Homebrew repository $tap" brew tap "$tap"; then
      return 1
    fi

    if ! runCommand "Install Homebrew package $display_name" brew install "$formula"; then
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

asdfPluginInstalled() {
  local plugin_name="$1"
  asdf plugin list 2>/dev/null | grep -qx "$plugin_name"
}

ensureAsdfPlugin() {
  local plugin_name="$1"
  local display_name="$2"
  local plugin_url="${3:-}"

  if asdfPluginInstalled "$plugin_name"; then
    info "$display_name asdf plugin is already added"
    return 0
  fi

  if [ -n "$plugin_url" ]; then
    runCommand "Add $display_name asdf plugin" asdf plugin-add "$plugin_name" "$plugin_url"
  else
    runCommand "Add $display_name asdf plugin" asdf plugin-add "$plugin_name"
  fi
}

installAsdfToolFromToolVersions() {
  local plugin_name="$1"
  local display_name="$2"
  local assertion_command="$3"
  local plugin_url="${4:-}"

  if ! cmdExists asdf; then
    fail "Failed to install $display_name. \`asdf\` is required to install."
    return 1
  fi

  if [ ! -f ~/.tool-versions ]; then
    fail "~/.tool-versions not found, cannot install $display_name via \`asdf\`."
    return 1
  fi

  success "Found ~/.tool-versions file"
  ensureAsdfPlugin "$plugin_name" "$display_name" "$plugin_url" || return 1

  info "Installing $display_name from ~/.tool-versions: "$'\n'"---TOOLS---"$'\n'"$(cat ~/.tool-versions)"$'\n'"-----------"
  runCommand "Install $display_name with asdf" asdf install "$plugin_name" || return 1
  assertPackageInstallation "$assertion_command" "$display_name"
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
        runCommand "Remove existing application $app_name" rm -rf "/Applications/$app_name" || return 1
        runCommand "Reinstall Homebrew cask $cask_name" brew reinstall --cask "$cask_name" || return 1
        if [ -n "$configure_function" ]; then
          "$configure_function"
        fi
      else
        info "Skipping overwrite..."
      fi
    else
      runCommand "Install Homebrew cask $cask_name" brew install --cask "$cask_name" || return 1
      if [ -n "$configure_function" ]; then
        "$configure_function"
      fi
    fi
    assertAppInstallation "$app_name"
  else
    info "Skipping Installation..."
  fi
}
