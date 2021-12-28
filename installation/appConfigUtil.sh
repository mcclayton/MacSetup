#!/bin/bash

###################################
# Package Configuration Functions #
###################################

# Set up yarn
configureYarn() {
    if grep -Fxq 'export PATH="$PATH:'`yarn global bin`'"' ~/.bash_profile; then
      info "yarn bin path already configured in bash_profile."
    elif cmdExists yarn; then
      # Configure yarn bin path
      info "Configuring yarn in .bash_profile and .zprofile"
      addLineToFiles "" ~/.bash_profile ~/.zprofile
      addLineToFiles "# Add yarn bin to PATH" ~/.bash_profile ~/.zprofile
      addLineToFiles 'export PATH="$PATH:'`yarn global bin`'"' ~/.bash_profile ~/.zprofile

      success 'Added line "export PATH="$PATH:'`yarn global bin`'"" to ~/.bash_profile and ~/.zprofile'
    else
      fail "Cannot configure yarn as it is not installed"
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
            for extension in `grep -v "^$" "$(scriptDirectory)/VSCode/extensions.list"`; do
                code --install-extension $extension
            done

            addLineToFiles "" ~/.bash_profile ~/.zprofile
            addLineToFiles "# Add Visual Studio Code (code)" ~/.bash_profile ~/.zprofile
            addLineToFiles 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' ~/.bash_profile ~/.zprofile
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
