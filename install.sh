#!/bin/bash

# HELPER FUNCTIONS

prompt() {
    echo "   => $1 "
    read -p "      [Y/n] " -r
    echo
}

warn() {
    echo "⚠ $1"
}

info() {
    echo "Info: $1"
    echo
}

success() {
    echo "-> $1 ✔"
}

fail() {
    echo "-> $1 ✘"
}

assertInstallation() {
    # $1 is command to assert existence in order to verify correct installation
    # $2 is command to assert existence in order to verify correct installation
    if hash $1 2>/dev/null; then
        success "Successfully installed $2"
    else
        fail "Failed to install $2"
    fi
}

promptNewSection() {
    echo
    echo "|=== $1 ===|"
    prompt "Proceed with section?"
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
        info "Brew is already installed"
    else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Test to ensure successful install
    assertInstallation brew "homebrew"
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
    info "Replacing top-level dot files"
    # Backup top-level dot files
    mkdir -p ~/dotfileBackups
    cp ~/.bashrc ~/dotfileBackups/.bashrc
    success "Backed up ~/.bashrc to ~/dotfileBackups/.bashrc"
    cp ~/.bash_profile ~/dotfileBackups/.bash_profile
    success "Backed up ~/.bash_profile to ~/dotfileBackups/.bash_profile"
    cp ~/.vimrc ~/dotfileBackups/.vimrc
    success "Backed up ~/.vimrc to ~/dotfileBackups/.vimrc"
    cp ~/.profile ~/dotfileBackups/.profile
    success "Backed up ~/.profile to ~/dotfileBackups/.profile"

    # Set new top-level dot files
    cp ./'Mac Dot Files'/bashrc.txt ~/.bashrc
    success "~/.bashrc set"
    cp ./'Mac Dot Files'/bash_profile.txt ~/.bash_profile
    success "~/.bash_profile set"
    cp ./'Mac Dot Files'/vimrc.txt ~/.vimrc
    success "~/.vimrc set"
    cp ./'Mac Dot Files'/profile.txt ~/.profile
    success "~/.profile set"
else
    # Skip this installation section
    info "Skipping..."
fi

# Set up .vim folder
promptNewSection "SETTING UP .VIM FOLDER"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Setting up .vim folder"
    # Backup files
    mkdir -p ~/dotfileBackups
    rm -rf ~/dotfileBackups/.vim
    cp -r ~/.vim ~/dotfileBackups/.vim
    info "Backed up ~/.vim to ~/dotfileBackups/.vim"

    # Set .vim folder
    rm -rf ~/.vim
    cp -r ./vim ~/.vim
    success "~/.vim folder set"
else
    # Skip this installation section
    info "Skipping..."
fi


# Get vim plugins
promptNewSection "FETCHING VIM PLUGINS"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Cloning plugins"
    git clone https://github.com/vim-airline/vim-airline.git ~/.vim/bundle/vim-airline
    success "vim-airline plugin added"
    git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
    success "nerdtree plugin added"
    git clone https://github.com/ervandew/supertab.git ~/.vim/bundle/supertab
    success "supertab plugin added"
    git clone git://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
    success "vim-fugitive plugin added"
else
    # Skip this installation section
    info "Skipping..."
fi


# Get packages
#promptNewSection "PACKAGES"
#if [[ $REPLY =~ ^[Yy]$ ]]; then
#    info "Installing lolcat"
#    if hash lolcat 2>/dev/null; then
#        info "lolcat is already installed"
#    else
#        gem install lolcat
#    fi
#    # Test to ensure successful install'
#    assertInstallation lolcat "lolcat"
#else
#    # Skip this installation section
#    info "Skipping..."
#fi


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
    cp -r ./spectacle/Spectacle.app /Applications/Spectacle.app
    info "Setting up shortcut preferences"
    cp ./spectacle/Shortcuts.json ~/Library/'Application Support'/Spectacle/Shortcuts.json
    success "Spectacle Shortcuts.json set"
    info "Opening Spectacle.app"
    open /Applications/Spectacle.app
    success "Spectacle.app added to Application"
else
    # Skip this installation section
    info "Skipping..."
fi
