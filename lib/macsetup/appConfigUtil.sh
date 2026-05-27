#!/bin/bash

###################################
# Package Configuration Functions #
###################################

configureICU4C() {
  info "Configuring icu4c"
  ICU_PATH=$(brew --prefix icu4c)
  # Add To Path
  addManagedLinesToFiles "Add icu4c to path" ~/.bash_profile ~/.zprofile -- \
    "" \
    "# Add icu4c to path" \
    "$(pathPrependShellLine "$ICU_PATH/bin")" \
    "$(pathPrependShellLine "$ICU_PATH/sbin")"
  # Enable Compilers to find icu4c
  addManagedLinesToFiles "Enable compilers to find icu4c" ~/.bash_profile ~/.zprofile -- \
    "" \
    "# Enable compilers to find icu4c" \
    "export LDFLAGS=\"-L$ICU_PATH/lib\"" \
    "export CPPFLAGS=\"-I$ICU_PATH/include\""
  # Enable pkg-config to find icu4c
  addManagedLinesToFiles "Enable pkg-config to find icu4c" ~/.bash_profile ~/.zprofile -- \
    "" \
    "# Enable pkg-config to find icu4c" \
    "export PKG_CONFIG_PATH=\"$ICU_PATH/lib/pkgconfig\""

  # Source in the changes
  [ -f ~/.bash_profile ] && source ~/.bash_profile
  [ -f ~/.zprofile ] && source ~/.zprofile
}

configureOpenSSL() {
  info "Configuring openssl"
  OPEN_SSL_PATH=$(brew --prefix openssl)
  # Add To Path
  addManagedLinesToFiles "Add openssl to path" ~/.bash_profile ~/.zprofile -- \
    "" \
    "# Add openssl to path" \
    "$(pathPrependShellLine "$OPEN_SSL_PATH/bin")" \
    "$(pathPrependShellLine "$OPEN_SSL_PATH/sbin")"

  # TODO: Need to make sure that this adds values to these env vars rather than directly
  # setting them

  # # Enable Compilers to find openssl
  # addLineToFiles "" ~/.bash_profile ~/.zprofile
  # addLineToFiles "# Enable compilers to find openssl" ~/.bash_profile ~/.zprofile
  # addLineToFiles "export LDFLAGS=\"-L$OPEN_SSL_PATH/lib\"" ~/.bash_profile ~/.zprofile
  # addLineToFiles "export CPPFLAGS=\"-I$OPEN_SSL_PATH/include\"" ~/.bash_profile ~/.zprofile
  # # Enable pkg-config to find openssl
  # addLineToFiles "" ~/.bash_profile ~/.zprofile
  # addLineToFiles "# Enable pkg-config to find openssl" ~/.bash_profile ~/.zprofile
  # addLineToFiles "export PKG_CONFIG_PATH=\"$OPEN_SSL_PATH/lib/pkgconfig\"" ~/.bash_profile ~/.zprofile

  # Source in the changes
  [ -f ~/.bash_profile ] && source ~/.bash_profile
  [ -f ~/.zprofile ] && source ~/.zprofile
}

configureBat() {
  info "Configuring bat"

  if cmdExists bat; then
    local bat_config_dir
    if ! bat_config_dir="$(bat --config-dir)"; then
      fail "Cannot configure bat. Failed to determine bat config directory"
      return
    fi

    local bat_theme_dir="$bat_config_dir/themes"
    local bat_theme_name="Catppuccin Macchiato.tmTheme"
    local bat_theme_source="$MACSETUP_ASSETS_DIR/bat/themes/$bat_theme_name"
    local bat_theme_destination="$bat_theme_dir/$bat_theme_name"

    if [ ! -f "$bat_theme_source" ]; then
      fail "Cannot configure bat. Theme asset not found: $bat_theme_source"
      return
    fi

    mkdir -p "$bat_theme_dir"
    if ! cp "$bat_theme_source" "$bat_theme_destination"; then
      fail "Failed to copy bat theme: $bat_theme_name"
      return
    fi

    assertFileExists "$bat_theme_destination" "bat theme installed: $bat_theme_name" "Failed to install bat theme: $bat_theme_name"

    if bat cache --build; then
      success "bat cache rebuilt"
    else
      fail "Failed to rebuild bat cache"
    fi
  else
    fail "Cannot configure bat because it is not installed"
  fi
}

#######################################
# Application Configuration Functions #
#######################################

# Set up VSCode
configureVSCode() {
  info "Configuring VSCode IDE"
  if [ -d "/Applications/Visual Studio Code.app" ]; then
    # Backup .vscode directory
    backupDir ~/.vscode vscode

    # Install VSCode Packages
    info "Installing VSCode Packages"
    if cmdExists code; then
      # For every non-blank line
      for extension in `grep -v "^$" "$MACSETUP_CONFIG_DIR/vscode/default/extensions.list"`; do
        code --install-extension $extension
      done

      info 'Adding VSCode to $PATH'
      addManagedLinesToFiles "Add Visual Studio Code (code)" ~/.bash_profile ~/.zprofile -- \
        "" \
        "# Add Visual Studio Code (code)" \
        "$(pathAppendShellLine '/Applications/Visual Studio Code.app/Contents/Resources/app/bin')"

      info 'Setting settings.json file'
      SETTINGS_PATH=~/Library/'Application Support'/Code/User/settings.json
      if [ -f "$SETTINGS_PATH" ]; then
        cp "$MACSETUP_CONFIG_DIR/vscode/default/settings.json" "$SETTINGS_PATH"
        assertFileExists "$SETTINGS_PATH" "Successfully updated settings.json file" "Could not update settings.json file"
      else
        warn "Could not automatically copy over settings.json"
        manualAction "For full configuration, please copy settings.json contents into VSCode settings"
      fi
    else
      fail "Failed to install VSCode Extensions, 'code' command does not exist"
    fi
  else
    fail "Cannot configure VSCode as it is not installed"
  fi
}

# Set up rectangle
configureRectangle() {
  info "Configuring Rectangle"
  if [ -d "/Applications/Rectangle.app" ]; then
    info "Setting up shortcut preferences"
    # Preserve white space by changing the Internal Field Separator
    IFS='%'
    mkdir -p ~/Library/'Application Support'/Rectangle
    cp "$MACSETUP_CONFIG_DIR/apps/rectangle/com.knollsoft.Rectangle.plist" ~/Library/Preferences/com.knollsoft.Rectangle.plist
    assertFileExists ~/Library/Preferences/com.knollsoft.Rectangle.plist "Rectangle Shortcuts set" "Failed to set Rectangle Shortcuts"
    # Reset the Internal Field Separator
    unset IFS
    info "Opening Rectangle.app"
    open /Applications/Rectangle.app
  else
    fail "Cannot configure Rectangle as it is not installed"
  fi
}

configureITerm() {
  info "Configuring iTerm"
  if [ -d "/Applications/iTerm.app" ]; then
    # Delete cached preferences
    info "Deleting cached iTerm preferences"
    defaults delete com.googlecode.iterm2
    # Copying over new configurations file
    info "Setting iTerm configurations file in ~/Library/Preferences/"
    cp "$MACSETUP_CONFIG_DIR/terminal/iterm2/com.googlecode.iterm2.plist" ~/Library/Preferences/com.googlecode.iterm2.plist
    # Reading in new config file
    info "Reading in new configurations file"
    defaults read -app iTerm >/dev/null 2>&1 || true
    # Assert configuration file was copied over successfully
    assertFileExists ~/Library/Preferences/"com.googlecode.iterm2.plist" "iTerm config file set correctly" "Failed to set iTerm config file"
  else
    fail "Cannot configure iTerm as it is not installed"
  fi
}

configureGhostty() {
  info "Configuring Ghostty"

  local applications_dir="${MACSETUP_APPLICATIONS_DIR:-/Applications}"
  local ghostty_app="$applications_dir/Ghostty.app"
  local ghostty_config_source="$MACSETUP_CONFIG_DIR/terminal/ghostty/config"
  local ghostty_config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  local ghostty_config_destination="$ghostty_config_dir/config"

  if [ ! -d "$ghostty_app" ]; then
    fail "Cannot configure Ghostty as it is not installed"
    return
  fi

  if [ ! -f "$ghostty_config_source" ]; then
    fail "Cannot configure Ghostty. Config asset not found: $ghostty_config_source"
    return
  fi

  backupFile "$ghostty_config_destination" ghostty-config
  if ! mkdir -p "$ghostty_config_dir"; then
    fail "Failed to create Ghostty config directory: $ghostty_config_dir"
    return
  fi

  if ! cp "$ghostty_config_source" "$ghostty_config_destination"; then
    fail "Failed to copy Ghostty config"
    return
  fi

  assertFileExists "$ghostty_config_destination" "Ghostty config file set correctly" "Failed to set Ghostty config file"
}

configureDocker() {
  manualAction "Open the Docker Desktop Application and grant priveledged access"
}
