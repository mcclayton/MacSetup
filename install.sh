#!/bin/bash

# Intro
echo " _____           _        _ _ "
echo "|_   _|         | |      | | |"
echo "  | |  _ __  ___| |_ __ _| | |"
echo "  | | | '_ \/ __| __/ _\` | | |"
echo " _| |_| | | \__ \ || (_| | | |"
echo "|_____|_| |_|___/\__\__,_|_|_|"
echo ""

prompt() {
    echo "   => $1 "
    read -p "      [Y/n] " -r
    echo
}

info() {
    echo "Info: $1"
    echo
}

success() {
    echo "-> $1 ✔"
}

promptNewSection() {
    echo
    echo "|=== $1 ===|"
    prompt "Proceed with section?"
}

manualAction() {
    echo "[MANUAL ACTION REQUIRED]: $1"
    read -p "   => Press Enter To Continue:"
}

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
