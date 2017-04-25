#!/bin/bash

###############################
# Application Setup Functions #
###############################

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
        cp ./Atom/config.cson ~/.atom/config.cson
        # Assert config.csno set correctly
        assertFileExists ~/.atom/config.cson "Atom config.cson set" "Failed to set Atom config.cson"

        # Install Atom Packages
        info "Installing Atom Packages"
        if hash apm 2>/dev/null; then
            # For every non-blank line
            for packageNameAndVersion in `grep -v "^$" ./Atom/packages.list`; do
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
        cp ./Spectacle/Shortcuts.json ~/Library/'Application Support'/Spectacle/Shortcuts.json
        assertFileExists ~/Library/'Application Support'/Spectacle/Shortcuts.json "Spectacle Shortcuts.json set" "Failed to set Spectacle Shortcuts.json"
        # Reset the Internal Field Separator
        unset IFS
        info "Opening Spectacle.app"
        open /Applications/Spectacle.app
    else
        fail "Cannot configure Spectacle as it is not installed"
    fi
}
