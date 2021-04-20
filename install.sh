#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

# Bring in constants
source "$(scriptDirectory)/installation/constants.sh"
# Bring in the helper functions
source "$(scriptDirectory)/installation/helperFunctions.sh"
# Bring in the application configuration util
source "$(scriptDirectory)/installation/appConfigUtil.sh"

# Main Function
function main {
  # Print out the intro message
  printIntro

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
    cp "$(scriptDirectory)/gitconfig.txt" ~/.gitconfig
    assertFileExists ~/.gitconfig "~/.gitconfig set" "Failed to set ~/.gitconfig"

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

  # Set up fonts
  promptNewSection "SETTING UP FONTS"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      info "Opening Inconsolata-g.otf font"
      open "$(scriptDirectory)/fonts/Inconsolata-g.otf"
      manualAction "Press Install Font Button for Inconsolata-g.otf"

      info "Opening Powerline Inconsolata-g font"
      open "$(scriptDirectory)/fonts/'Inconsolata-g for Powerline.otf'"
      manualAction "Press Install Font Button for Inconsolata-g for Powerline.otf"
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi

    # Set up fonts
  promptNewSection "SETTING UP SCREENSAVERS"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      info "Opening Aerial.saver"
      open "$(scriptDirectory)/screensavers/Aerial.saver"
      manualAction "Follow MacOSX prompts to install Aerial.saver"
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
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
      "utility_aliases"
    )

    info "Backing up top-level dot files"

    # Backup Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
      backupFile ~/."$dotFileName" ~/dotfileBackups/."$dotFileName"
    done

    info "Setting top-level dot files"

    # Set Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
      cp "$(scriptDirectory)"/Mac_Dot_Files/"$dotFileName".sh ~/."$dotFileName"
      assertFileExists ~/."$dotFileName" "~/.$dotFileName set" "Failed to set ~/.$dotFileName"
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
    cp -r "$(scriptDirectory)/vim" ~/.vim
    assertDirectoryExists ~/.vim "~/.vim directory set" "Failed to set ~/.vim directory"

    # Backup .vimrc
    mkdir -p ~/dotfileBackups
    backupFile ~/.vimrc ~/dotfileBackups/.vimrc

    # Set .vimrc
    cp "$(scriptDirectory)"/Mac_Dot_Files/vimrc.sh ~/.vimrc
    assertFileExists ~/.vimrc "~/.vimrc set" "Failed to set ~/.vimrc"
    success "~/.vimrc set"

    # Clone all vim plugins
    vimPlugins=(
      "git://github.com/vim-airline/vim-airline.git"
      "git://github.com/scrooloose/nerdtree.git"
      "git://github.com/ervandew/supertab.git"
      "git://github.com/tpope/vim-fugitive.git"
      "git://github.com/airblade/vim-gitgutter.git"
      "git://github.com/junegunn/fzf.git"
    )

    info "Cloning plugins"
    for pluginUrl in "${vimPlugins[@]}"; do
      repoName=$(repoName "$pluginUrl")
      cloneToPath=~/".vim/bundle/$repoName"
      rm -rf "$cloneToPath"
      git clone "$pluginUrl" "$cloneToPath"
      # Invoke installation script if exists (i.e. for fzf)
      installPath="$cloneToPath/install"
      if [ -f $installPath ]; then
        echo -e "\n\nInvoking installation for $repoName\n"
        $installPath
      fi
      assertDirectoryExists "$cloneToPath" "$repoName plugin added to $cloneToPath" "Failed to add plugin $repoName to $cloneToPath"
    done
  else
      # Skip this installation section
      info "Skipping..."
  fi

  # Set up asdf and tools (Postgres, Ruby, Node)
  promptNewSection "ASDF Version Manager + (Postgres & Ruby & Node)"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    local currDir="$(scriptDirectory)";
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    cd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"

    source $HOME/.asdf/asdf.sh
    assertPackageInstallation asdf "asdf"
    cd "$currDir"

    info "Configuring asdf version manager in .bash_profile"
    echo >> ~/.bash_profile
    echo "# asdf version manager" >> ~/.bash_profile
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
    success 'Added asdf configuration to ~/.bash_profile'

    info "Configuring asdf version manager in .zshrc"
    echo >> ~/.bash_profile
    echo "# asdf version manager" >> ~/.bash_profile
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
    success 'Added asdf configuration to ~/.zshrc'

    info "Adding Ruby Plugin..."
    asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
    info "Adding Postgres Plugin..."
    asdf plugin-add postgres
    info "Adding Node Plugin..."
    asdf plugin-add nodejs

    info "Backing up ~/.tool-versions"
    backupFile ~/.tool-versions ~/dotfileBackups/.tool-versions

    cp "$(scriptDirectory)"/.tool-versions ~/.tool-versions
    assertFileExists ~/.tool-versions "~/.tool-versions set" "Failed to set ~/.tool-versions"

    promptYesNo "Would you like to install tools in ~/.tool-versions? (This will take a while)"$'\n'"---TOOLS---"$'\n'"$(cat ~/.tool-versions)"$'\n'"-----------"$
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      info "Installing Tools in .tool-versions"
      asdf install
      assertPackageInstallation ruby "ruby"
      assertPackageInstallation node "node"
      assertPackageInstallation postgres "postgres"
    fi
  fi

  # Set up homebrew
  promptNewSection "HOMEBREW PACKAGE MANAGER"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      info "Installing Homebrew package manager"
      if hash ruby 2>/dev/null; then
        # Install Brew if it isn't already
        if hash brew 2>/dev/null; then
          info "Homebrew is already installed"
        else
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        manualAction "If Homebrew installed successfully, please follow Homebrew's above instructions (in another tab) to add it to your path."
        source ~/.bash_profile

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
        fail "Ruby is required first to install homebrew."
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
      installPackage curl "brew install curl"
      assertPackageInstallation curl "curl"
      # Install tree
      installPackage tree "brew install tree"
      assertPackageInstallation tree "tree"
      # Install gpg
      installPackage gpg "brew install gpg"
      assertPackageInstallation gpg "gpg"
      # Install ack
      installPackage ack "brew install ack"
      assertPackageInstallation ack "ack"
      # Install yarn
      installPackage yarn "brew install yarn" configureYarn
      assertPackageInstallation yarn "yarn"
      # Install htop
      installPackage htop "brew install htop"
      assertPackageInstallation htop "htop"
      # Install ytop
      installPackage ytop "(brew tap cjbassi\/ytop) && (brew install ytop)"
      assertPackageInstallation ytop "ytop"
      # Install bat
      installPackage bat "brew install bat"
      assertPackageInstallation bat "bat"
      # Install
      installPackage icu4c "brew install icu4c"
      assertPackageInstallation icuinfo "icu4c"
    else
      fail "Failed to install brew packages. Homebrew is not installed."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi

  # Get Applications
  promptNewSection "APPLICATIONS"
  if [[ $REPLY =~ ^[Yy]$ ]]; then

    if isMacOs; then
      # Can only install brew apps if brew is installed
      if hash brew 2>/dev/null; then
        # Install Caffeine
        caskInstallAppPrompt "Caffeine.app" "caffeine"
        # Install Sip Color Picker
        caskInstallAppPrompt "Sip.app" "sip"
        # Install Flux
        caskInstallAppPrompt "Flux.app" "flux"
        # Install Postman
        caskInstallAppPrompt "Postman.app" "postman"
        # Install Spotify
        caskInstallAppPrompt "Spotify.app" "spotify"
        # Install Slack
        caskInstallAppPrompt "Slack.app" "slack"
        # Install VirtualBox
        caskInstallAppPrompt "VirtualBox.app" "virtualbox"
        # Install Firefox
        caskInstallAppPrompt "Firefox.app" "firefox"
        # Install Gimp
        caskInstallAppPrompt "Gimp.app" "gimp"
        # Install Docker
        caskInstallAppPrompt "Docker.app" "docker"
        # Preserve white space by changing the Internal Field Separator
        IFS='%'
        # Install and configure Chrome
        caskInstallAppPrompt "Google Chrome.app" "google-chrome"
        # Reset the Internal Field Separator
        unset IFS

        # Install applications that need configuring
        # Install Spectacle
        caskInstallAppPrompt "Spectacle.app" "spectacle" configureSpectacle
        # Install Visual Studio Code
        caskInstallAppPrompt "Visual Studio Code.app" "visual-studio-code" configureVSCode
        # Install and configure iTerm2
        caskInstallAppPrompt "iTerm.app" "iterm2" configureITerm

        # Cleanup downloads
        info "Cleaning up application .zip and .dmg files"
        brew cleanup
      else
        fail "Failed to install brew packages. Homebrew is not installed."
      fi
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi

  finish
}


##############
# Start Main #
##############

# Trap interrupts and call finish
trap finish INT

main
