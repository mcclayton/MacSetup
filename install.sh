#!/bin/bash

# FONT COLORS
RED=$(tput setaf 9)
ORANGE=$(tput setaf 172)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 12)
YELLOW=$(tput setaf 11)
GRAY=$(tput setaf 8)
RESET_COLOR=$(tput sgr0)

# HELPER FUNCTIONS

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
        warn "$1 Does not exist, skipping backup"
    else
        cp $1 $2
        success "Backed up $1 to $2"
    fi
}

# Backs up file $1 (if it exists) to location $2
backupDir() {
    if [ ! -f $1 ]; then
        warn "$1 Does not exist, skipping backup"
    else
        cp -r $1 $2
        success "Backed up $1 to $2"
    fi
}

# Install package $1 via the command $2.
installPackage() {
    info "Installing $1"
    if hash $1 2>/dev/null; then
        info "$1 is already installed"
    else
        $2
    fi
}

assertInstallation() {
    # $1 is command to assert existence in order to verify correct installation
    # $2 is name of command
    if hash $1 2>/dev/null; then
        success "Successfully installed $2"
    else
        fail "Failed to install $2"
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
    assertInstallation gcc "Xcode CLT"
    assertInstallation git "Git"
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
    assertInstallation brew "homebrew"

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

# Get packages
promptNewSection "PACKAGES"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Install lolcat
    installPackage lolcat "gem install lolcat"
    assertInstallation lolcat "lolcat"
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


# Set up Atom
promptNewSection "ATOM IDE"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Moving Atom.app to Applications"
    rm -rf /Atom/Atom.app
    cp -r ./Atom/Atom.app /Applications/Atom.app
    success "Atom.app added to Application"
    info "Configuring Atom IDE"

    # Backup .atom directory
    mkdir -p ~/dotfileBackups
    rm -rf ~/dotfileBackups/.atom
    backupDir ~/.atom ~/dotfileBackups/.atom

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

# Set up spectacle
promptNewSection "SETTING UP SPECTACLE WINDOW MANAGER"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Moving Spectacle.app to Applications"
    rm -rf /Applications/Spectacle.app
    cp -r ./Spectacle/Spectacle.app /Applications/Spectacle.app
    info "Setting up shortcut preferences"
    cp ./Spectacle/Shortcuts.json ~/Library/'Application Support'/Spectacle/Shortcuts.json
    success "Spectacle Shortcuts.json set"
    info "Opening Spectacle.app"
    open /Applications/Spectacle.app
    success "Spectacle.app added to Application"
else
    # Skip this installation section
    info "Skipping..."
fi

# Finish
echo
echo -e "$BLUE INSTALLATION COMPLETE.$RESET_COLOR"
echo
