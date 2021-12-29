#!/bin/bash

###################################
# Package Configuration Functions #
###################################

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
        for extension in `grep -v "^$" "$(scriptDirectory)/VSCode/extensions.list"`; do
          code --install-extension $extension
        done

        info 'Adding VSCode to $PATH'
        addLineToFiles "" ~/.bash_profile ~/.zprofile
        addLineToFiles "# Add Visual Studio Code (code)" ~/.bash_profile ~/.zprofile
        addLineToFiles 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' ~/.bash_profile ~/.zprofile

        info 'Setting settings.json file'
        SETTINGS_PATH=~/Library/'Application Support'/Code/User/settings.json
        if [ -f "$SETTINGS_PATH" ]; then
          cp "$(scriptDirectory)/VSCode/settings.json" "$SETTINGS_PATH"
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
        cp "$(scriptDirectory)/Rectangle/com.knollsoft.Rectangle.plist" ~/Library/Preferences/com.knollsoft.Rectangle.plist
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
    if [ -d "/Applications/iTerm.app" ]; then
        # Delete cached preferences
        info "Deleting cached iTerm preferences"
        defaults delete com.googlecode.iterm2
        # Copying over new configurations file
        info "Setting iTerm configurations file in ~/Library/Preferences/"
        cp "$(scriptDirectory)/iTerm2/com.googlecode.iterm2.plist" ~/Library/Preferences/com.googlecode.iterm2.plist
        # Reading in new config file
        info "Reading in new configurations file"
        `defaults read -app iTerm` 2>/dev/null
        # Assert configuration file was copied over successfully
        assertFileExists ~/Library/Preferences/"com.googlecode.iterm2.plist" "iTerm config file set correctly" "Failed to set iTerm config file"
    else
        fail "Cannot configure iTerm as it is not installed"
    fi
}
