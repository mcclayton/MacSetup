#!/bin/bash

# FONT COLORS
RED=$(tput setaf 9)
ORANGE=$(tput setaf 172)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 12)
YELLOW=$(tput setaf 11)
GRAY=$(tput setaf 8)
RESET_COLOR=$(tput sgr0)

####################
# Helper Functions #
####################

promptYesNo() {
    echo "   => $1 "
    read -p "      [Y/n] " -r
    echo
}

prompt() {
    IFS= read -r -p "   => $1 "
    echo
}

warn() {
    echo "$YELLOW ⚠ $1 $RESET_COLOR"
    echo
}

info() {
    echo -e "$GRAY ⓘ $1 $RESET_COLOR"
    echo
}

success() {
    echo -e "$GREEN ✔ $1 $RESET_COLOR"
    echo
}

fail() {
    echo -e "$RED ✘ $1 $RESET_COLOR"
    echo
}

# Gets the repo name given a full git url
repoName() {
    # Get the name of the repo in format 'myRepo.git'
    basename=$(basename $1)
    # Echo out repo name in format 'myRepo'
    echo "${basename%.*}"
}

# Backs up file $1 (if it exists) to location $2
backupFile() {
    if [ ! -f $1 ]; then
        warn "$1 Does not exist, skipping backup..."
    else
        cp $1 $2
        success "Backed up $1 to $2"
    fi
}

# Backs up directory $1 (if it exists) to location $2
backupDir() {
    if [ ! -d $1 ]; then
        warn "$1 Does not exist, skipping backup..."
    else
        cp -r $1 $2
        success "Backed up $1 to $2"
    fi
}

# Install package $1 via the command $2.
installPackage() {
    info "Installing Package: $1"
    if hash $1 2>/dev/null; then
        info "$1 is already installed"
    else
        $2
    fi
}


# Install application named $1 via the cask name $2 only if it does
# not already exist at path /Applications/$1
# Configure via command $3 if passed
caskInstallAppPrompt() {
    promptYesNo "Install application $1?"

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Install Application
        info "Installing Application: $1"
        if brew cask ls --versions $2 > /dev/null; then
            warn "$1 is already installed. Prompting overwrite..."
            promptYesNo "Do you want to $RED OVERWRITE $RESET_COLOR application $1?"
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "/Applications/$1"
                # Run re-install command
                brew cask reinstall $2
                # Run Config Command if present
                if [ ! -z "$3" ]; then
                    $3
                fi
            else
                info "Skipping overwrite..."
            fi
        else
            # Run install command
            brew cask install $2
            # Run Config Command if present
            if [ ! -z "$3" ]; then
                $3
            fi
        fi
        # Assert application is installed correctly
        assertAppInstallation $1
    else
        # Skip this installation section
        info "Skipping Installation..."
    fi
}

assertPackageInstallation() {
    # $1 is command to assert existence in order to verify correct installation
    # $2 is name of command
    if hash $1 2>/dev/null; then
        success "Successfully installed $2"
    else
        fail "Failed to install $2"
    fi
}

assertAppInstallation() {
    # Assert application $1 exists at /Applications/$1
    if [ -d "/Applications/$1" ]; then
        success "Successfully installed $1 and added to Applications"
    else
        fail "Failed to install $1"
    fi
}

promptNewSection() {
    echo
    echo "$ORANGE[=== $1 ===] $RESET_COLOR"
    promptYesNo "Proceed with section?"
}

manualAction() {
    echo -e "[MANUAL ACTION REQUIRED]: $1"
    read -p "   => Press Enter To Continue:"
}


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
        cp ./Atom/config.cson ~/.atom/config.cson
        success "Atom config.cson set"

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
setupSpectacle() {
    info "Configuring Spectacle"
    if [ -d "/Applications/Spectacle.app" ]; then
        info "Setting up shortcut preferences"
        cp ./Spectacle/Shortcuts.json ~/Library/'Application Support'/Spectacle/Shortcuts.json
        success "Spectacle Shortcuts.json set"
        info "Opening Spectacle.app"
        open /Applications/Spectacle.app
    else
        fail "Cannot configure Spectacle as it is not installed"
    fi
}

########
# Main #
########

# Intro
echo " _____           _        _ _ "
echo "|_   _|         | |      | | |"
echo "  | |  _ __  ___| |_ __ _| | |"
echo "  | | | '_ \/ __| __/ _\` | | |"
echo " _| |_| | | \__ \ || (_| | | |"
echo "|_____|_| |_|___/\__\__,_|_|_|"
echo ""

# Check to make sure script is not initially run as root.
if [ "$EUID" -eq 0 ]
  then
  warn "Please do not run entire script as root."
  info "Exiting..."
  exit
fi

# Set up Xcode command line tools
promptNewSection "XCODE COMMAND LINE TOOLS"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Installing Xcode Command Line Tools"
    xcode-select --install
    # Test to ensure successful install
    assertPackageInstallation gcc "Xcode CLT"
    assertPackageInstallation git "Git"
else
    # Skip this installation section
    info "Skipping..."
fi

# Set up Git
promptNewSection "GIT"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Configuring git"
    # Backup files
    mkdir -p ~/dotfileBackups
    backupFile ~/.gitconfig ~/dotfileBackups/.gitconfig

    # Set .gitconfig
    cp ./gitconfig.txt ~/.gitconfig
    success "~/.gitconfig set"
    # Set Github Username and email
    prompt "What is your Github Username (i.e. \"First Last\")?"
    git config --global user.name "$REPLY"
    success "Username set to $REPLY"
    prompt "What is your Github Email (i.e. \"me@mail.com\")?"
    success "Email set to $REPLY"
    git config --global user.email $REPLY
else
    # Skip this installation section
    info "Skipping..."
fi

# Set up homebrew
promptNewSection "HOMEBREW PACKAGE MANAGER"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Installing Homebrew package manager"
    # Install Brew if it isn't already
    if hash brew 2>/dev/null; then
        info "Homebrew is already installed"
    else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Test to ensure successful install
    assertPackageInstallation brew "homebrew"

    if hash brew 2>/dev/null; then
        info "Updating homebrew"
        brew update
        info "Making homebrew healthy with brew doctor"
        brew doctor
    else
        fail "Failed to update Homebrew because it is not installed"
    fi
else
    # Skip this installation section
    info "Skipping..."
fi

# Get Applications
promptNewSection "APPLICATIONS"
if [[ $REPLY =~ ^[Yy]$ ]]; then

    # Can only install brew apps if brew is installed
    if hash brew 2>/dev/null; then
        # Install Flux
        caskInstallAppPrompt "Flux.app" "flux"
        # Install Postman
        caskInstallAppPrompt "Postman.app" "postman"
        # Install Spectacle
        caskInstallAppPrompt "Spectacle.app" "spectacle" setupSpectacle
        # Install and configure Atom
        caskInstallAppPrompt "Atom.app" "atom" configureAtom
    else
        fail "Failed to install brew packages. Homebrew is not installed."
    fi
else
    # Skip this installation section
    info "Skipping..."
fi

# Get packages
promptNewSection "PACKAGES"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Install lolcat
    installPackage lolcat "gem install lolcat"
    assertPackageInstallation lolcat "lolcat"

    # Can only install brew packages if brew is installed
    if hash brew 2>/dev/null; then
        # Install wget
        installPackage wget "brew install wget"
        assertPackageInstallation wget "wget"
        # Install curl
        installPackage wget "brew install curl"
        assertPackageInstallation curl "curl"
        # Install tree
        installPackage tree "brew install tree"
        assertPackageInstallation tree "tree"
    else
        fail "Failed to install brew packages. Homebrew is not installed."
    fi
else
    # Skip this installation section
    info "Skipping..."
fi

# Get NODE, NPM, and NVM
promptNewSection "NODE, NPM, AND NVM"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Can only install brew packages if brew is installed
    if hash brew 2>/dev/null; then
        # Install nvm
        installPackage nvm "brew install nvm"

        # Configure and source nvm
        export NVM_DIR="$HOME/.nvm"
        . "/usr/local/opt/nvm/nvm.sh"

        # Assert correct installation
        assertPackageInstallation nvm "nvm"

        # Update nvm config in bash_profile if not already set
        if grep -Fxq 'export NVM_DIR="$HOME/.nvm"' ~/.bash_profile; then
            info "NVM is already configured in bash_profile."
        else
            info "Configuring NVM in bash_profile"
            echo >> ~/.bash_profile
            echo "# Set NVM Directory" >> ~/.bash_profile
            echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
            info 'Added line "export NVM_DIR="$HOME/.nvm"" to ~/.bash_profile'
        fi

        # Source nvm.sh scrip
        if grep -Fxq '. "/usr/local/opt/nvm/nvm.sh"' ~/.bash_profile; then
            info "NVM shell script sourcing is already configured in bash_profile."
        else
            info "Configuring NVM shell script sourcing in bash_profile"
            echo >> ~/.bash_profile
            echo "# Source nvm.sh script" >> ~/.bash_profile
            echo '. "/usr/local/opt/nvm/nvm.sh"' >> ~/.bash_profile
            info 'Added line ". "/usr/local/opt/nvm/nvm.sh"" to ~/.bash_profile'
        fi

        # Make .nvmrc directory if necessary
        if [ ! -d ~/.nvmrc ]; then
            info "~/.nvmrc does not exist, creating it..."
            mkdir ~/.nvmrc
            success "Created ~/.nvmrc directory"
        else
            info "~/.nvmrc directory already exists, skipping creation..."
        fi

        # Install Node.js
        info "Installing Node.js via nvm"
        prompt "What version number of Node would like to install? (Leave blank for latest stable) "
        NODE_VERSION=$REPLY
        if [[ -z $NODE_VERSION ]]; then
            # Install latest stable version
            nvm install stable
            NODE_VERSION="stable"
        else
            # Install user specified version
            nvm install $NODE_VERSION
        fi

        # Assert correct installation
        assertPackageInstallation node "node"
        assertPackageInstallation npm "npm"

        # Use Stable verion of node
        nvm use $NODE_VERSION
        nvm ls
        success "Successfully using Version Node.js: `nvm current`"
    else
        fail "Failed to install brew packages. Homebrew is not installed."
    fi
else
    # Skip this installation section
    info "Skipping..."
fi

# Set up fonts
promptNewSection "SETTING UP FONTS"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Opening Inconsolata-g.otf font"
    open ./fonts/Inconsolata-g.otf
    manualAction "Press Install Font Button for Inconsolata-g.otf"

    info "Opening Powerline Inconsolata-g font"
    open ./fonts/'Inconsolata-g for Powerline.otf'
    manualAction "Press Install Font Button for Inconsolata-g for Powerline.otf"
else
    # Skip this installation section
    info "Skipping..."
fi

promptNewSection "SETTING UP TOP-LEVEL DOT FILES"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Set new top-level dot files
    topLevelDotFiles=(
      "bashrc"
      "bash_profile"
      "profile"
    )

    info "Backing up top-level dot files"

    # Backup Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
        backupFile ~/."$dotFileName" ~/dotfileBackups/."$dotFileName"
    done

    info "Setting top-level dot files"

    # Set Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
        cp ./'Mac Dot Files'/"$dotFileName".txt ~/."$dotFileName"
        success "~/.$dotFileName set"
    done
else
    # Skip this installation section
    info "Skipping..."
fi

# Set up vim
promptNewSection "SETTING UP VIM"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Set up .vim folder
    info "Setting up .vim folder"
    # Backup .vim folder
    mkdir -p ~/dotfileBackups
    rm -rf ~/dotfileBackups/.vim
    backupDir ~/.vim ~/dotfileBackups/.vim

    # Set .vim folder
    rm -rf ~/.vim
    cp -r ./vim ~/.vim
    success "~/.vim folder set"

    # Backup .vimrc
    mkdir -p ~/dotfileBackups
    backupFile ~/.vimrc ~/dotfileBackups/.vimrc

    # Set .vimrc
    cp ./'Mac Dot Files'/vimrc.txt ~/.vimrc
    success "~/.vimrc set"

    # Clone all vim plugins
    vimPlugins=(
      "git://github.com/vim-airline/vim-airline.git"
      "git://github.com/scrooloose/nerdtree.git"
      "git://github.com/ervandew/supertab.git"
      "git://github.com/tpope/vim-fugitive.git"
    )

    info "Cloning plugins"
    for pluginUrl in "${vimPlugins[@]}"; do
        repoName=$(repoName "$pluginUrl")
        cloneToPath="~/.vim/bundle/$repoName"
        rm -rf "$cloneToPath"
        git clone "$pluginUrl" ~/".vim/bundle/$repoName"
        success "$repoName plugin added to $cloneToPath"
    done
else
    # Skip this installation section
    info "Skipping..."
fi


# Set up iTerm2
promptNewSection "SETTING UP iTERM2"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Moving iTerm.app to Applications"
    rm -rf /Applications/iTerm.app
    cp -r ./iTerm2/iTerm.app /Applications/iTerm.app
    success "iTerm.app added to Application"

    info "Opening iTerm.app"
    open /Applications/iTerm.app
    manualAction "In iTerm, Go to: iTerm->Preferences->General and load preferences from a custom folder or URL.\n Select ./iTerm2/com.googlecode.iterm2.plist"
else
    # Skip this installation section
    info "Skipping..."
fi

# Finish
echo
echo -e "$BLUE INSTALLATION COMPLETE.$RESET_COLOR"
echo
