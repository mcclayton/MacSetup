#!/bin/bash

###################################
# Package Configuration Functions #
###################################

configureICU4C() {
  info "Configuring icu4c"
  local ICU_PATH=""
  runCommandOutputVariable ICU_PATH "Find Homebrew prefix for icu4c" brew --prefix icu4c || return 1
  # Add To Path
  addLineToFiles "" ~/.bash_profile ~/.zprofile
  addLineToFiles "# Add icu4c to path" ~/.bash_profile ~/.zprofile
  addLineToFiles "export PATH=\"$ICU_PATH/bin:\$PATH\"" ~/.bash_profile ~/.zprofile
  addLineToFiles "export PATH=\"$ICU_PATH/sbin:\$PATH\"" ~/.bash_profile ~/.zprofile
  # Enable Compilers to find icu4c
  addLineToFiles "" ~/.bash_profile ~/.zprofile
  addLineToFiles "# Enable compilers to find icu4c" ~/.bash_profile ~/.zprofile
  addLineToFiles "export LDFLAGS=\"-L$ICU_PATH/lib\"" ~/.bash_profile ~/.zprofile
  addLineToFiles "export CPPFLAGS=\"-I$ICU_PATH/include\"" ~/.bash_profile ~/.zprofile
  # Enable pkg-config to find icu4c
  addLineToFiles "" ~/.bash_profile ~/.zprofile
  addLineToFiles "# Enable pkg-config to find icu4c" ~/.bash_profile ~/.zprofile
  addLineToFiles "export PKG_CONFIG_PATH=\"$ICU_PATH/lib/pkgconfig\"" ~/.bash_profile ~/.zprofile

  # Source in the changes
  [ -f ~/.bash_profile ] && source ~/.bash_profile
  [ -f ~/.zprofile ] && source ~/.zprofile
}

configureOpenSSL() {
  info "Configuring openssl"
  local OPEN_SSL_PATH=""
  runCommandOutputVariable OPEN_SSL_PATH "Find Homebrew prefix for openssl" brew --prefix openssl || return 1
  # Add To Path
  addLineToFiles "" ~/.bash_profile ~/.zprofile
  addLineToFiles "# Add openssl to path" ~/.bash_profile ~/.zprofile
  addLineToFiles "export PATH=\"$OPEN_SSL_PATH/bin:\$PATH\"" ~/.bash_profile ~/.zprofile
  addLineToFiles "export PATH=\"$OPEN_SSL_PATH/sbin:\$PATH\"" ~/.bash_profile ~/.zprofile

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
    if ! runCommandOutputVariable bat_config_dir "Determine bat config directory" bat --config-dir; then
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

    runCommand "Create bat theme directory" mkdir -p "$bat_theme_dir" || return 1
    runCommand "Copy bat theme $bat_theme_name" cp "$bat_theme_source" "$bat_theme_destination" || return 1

    assertFileExists "$bat_theme_destination" "bat theme installed: $bat_theme_name" "Failed to install bat theme: $bat_theme_name"

    if runCommand "Rebuild bat cache" bat cache --build; then
      success "bat cache rebuilt"
    else
      return 1
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
      while IFS= read -r extension || [ -n "$extension" ]; do
        [ -z "$extension" ] && continue
        runCommand "Install VSCode extension $extension" code --install-extension "$extension" || return 1
      done < "$MACSETUP_CONFIG_DIR/vscode/default/extensions.list"

      info 'Adding VSCode to $PATH'
      addLineToFiles "" ~/.bash_profile ~/.zprofile
      addLineToFiles "# Add Visual Studio Code (code)" ~/.bash_profile ~/.zprofile
      addLineToFiles 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' ~/.bash_profile ~/.zprofile

      info 'Setting settings.json file'
      SETTINGS_PATH=~/Library/'Application Support'/Code/User/settings.json
      if [ -f "$SETTINGS_PATH" ]; then
        runCommand "Copy VSCode settings.json" cp "$MACSETUP_CONFIG_DIR/vscode/default/settings.json" "$SETTINGS_PATH" || return 1
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
    runCommand "Create Rectangle application support directory" mkdir -p ~/Library/'Application Support'/Rectangle || return 1
    runCommand "Copy Rectangle preferences" cp "$MACSETUP_CONFIG_DIR/apps/rectangle/com.knollsoft.Rectangle.plist" ~/Library/Preferences/com.knollsoft.Rectangle.plist || return 1
    assertFileExists ~/Library/Preferences/com.knollsoft.Rectangle.plist "Rectangle Shortcuts set" "Failed to set Rectangle Shortcuts"
    info "Opening Rectangle.app"
    runCommand "Open Rectangle.app" open /Applications/Rectangle.app || return 1
  else
    fail "Cannot configure Rectangle as it is not installed"
  fi
}

configureITerm() {
  info "Configuring iTerm"
  if [ -d "/Applications/iTerm.app" ]; then
    # Delete cached preferences
    info "Deleting cached iTerm preferences"
    runOptionalCommand "Delete cached iTerm preferences" defaults delete com.googlecode.iterm2 || true
    # Copying over new configurations file
    info "Setting iTerm configurations file in ~/Library/Preferences/"
    runCommand "Copy iTerm preferences" cp "$MACSETUP_CONFIG_DIR/terminal/iterm2/com.googlecode.iterm2.plist" ~/Library/Preferences/com.googlecode.iterm2.plist || return 1
    # Reading in new config file
    info "Reading in new configurations file"
    runOptionalCommand "Read iTerm defaults" defaults read -app iTerm || true
    # Assert configuration file was copied over successfully
    assertFileExists ~/Library/Preferences/"com.googlecode.iterm2.plist" "iTerm config file set correctly" "Failed to set iTerm config file"
  else
    fail "Cannot configure iTerm as it is not installed"
  fi
}

configureDocker() {
  manualAction "Open the Docker Desktop Application and grant priveledged access"
}
