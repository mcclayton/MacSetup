#!/bin/bash

###################################
# Package Configuration Functions #
###################################

# Set up yarn
configureYarn() {
    if grep -Fxq 'export PATH="$PATH:'`yarn global bin`'"' ~/.bash_profile; then
        info "yarn bin path already configured in bash_profile."
    elif hash yarn 2>/dev/null; then
        # Configure yarn bin path
        info "Configuring yarn in bash_profile"
        echo >> ~/.bash_profile
        echo "# Add yarn bin to PATH" >> ~/.bash_profile
        echo 'export PATH="$PATH:'`yarn global bin`'"' >> ~/.bash_profile
        success 'Added line "export PATH="$PATH:'`yarn global bin`'"" to ~/.bash_profile'
    else
        fail "Cannot configure yarn as it is not installed"
    fi
}

#######################################
# Application Configuration Functions #
#######################################

# Set up Atom
configureAtom() {
    info "Configuring Atom IDE"
    if [ -d "/Applications/Atom.app" ]; then
        # Backup .atom directory
        mkdir -p ~/dotfileBackups
        rm -rf ~/dotfileBackups/.atom
        backupDir ~/.atom ~/dotfileBackups/.atom
        # Set atom config file
        mkdir -p ~/.atom
        cp "$(scriptDirectory)/Atom/config.cson" ~/.atom/config.cson
        # Assert config.cson set correctly
        assertFileExists ~/.atom/config.cson "Atom config.cson set" "Failed to set Atom config.cson"

        # Set Atom snippets
        cp "$(scriptDirectory)/Atom/snippets.cson" ~/.atom/snippets.cson
        # Assert config.cson set correctly
        assertFileExists ~/.atom/snippets.cson "Atom snippets.cson set" "Failed to set Atom snippets.cson"

        # Install Atom Packages
        info "Installing Atom Packages"
        if hash apm 2>/dev/null; then
            # For every non-blank line
            for packageNameAndVersion in `grep -v "^$" "$(scriptDirectory)/Atom/packages.list"`; do
                apm install $packageNameAndVersion
            done
        else
            fail "Failed to install Atom Packages, apm does not exist"
        fi
    else
        fail "Cannot configure Atom as it is not installed"
    fi
}

# Set up spectacle
configureSpectacle() {
    info "Configuring Spectacle"
    if [ -d "/Applications/Spectacle.app" ]; then
        info "Setting up shortcut preferences"
        # Preserve white space by changing the Internal Field Separator
        IFS='%'
        mkdir -p ~/Library/'Application Support'/Spectacle/Shortcuts.json
        cp "$(scriptDirectory)/Spectacle/Shortcuts.json" ~/Library/'Application Support'/Spectacle/Shortcuts.json
        assertFileExists ~/Library/'Application Support'/Spectacle/Shortcuts.json "Spectacle Shortcuts.json set" "Failed to set Spectacle Shortcuts.json"
        # Reset the Internal Field Separator
        unset IFS
        info "Opening Spectacle.app"
        open /Applications/Spectacle.app
    else
        fail "Cannot configure Spectacle as it is not installed"
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
