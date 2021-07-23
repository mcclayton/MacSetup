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
  promptNewSection "XCODE COMMAND LINE TOOLS + GIT"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      info "Installing Xcode Command Line Tools"
      xcode-select --install
      # Test to ensure successful install
      assertPackageInstallation gcc "Xcode CLT"
      assertPackageInstallation git "Git"
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi

  # Set up Git
  promptNewSection "CONFIGURE GIT"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if cmdExists git; then
      info "Configuring git"
      # Backup files
      backupFile ~/.gitconfig gitconfig

      # Set .gitconfig
      cp "$(scriptDirectory)/gitconfig.txt" ~/.gitconfig
      assertFileExists ~/.gitconfig "~/.gitconfig set" "Failed to set ~/.gitconfig"

      # Backup global .gitignore
      info "Backing up global .gitignore"
      backupFile ~/.gitignore gitignore

      # Set Global Gitignore
      info "Setting global .gitignore"
      cp "$(scriptDirectory)"/Mac_Dot_Files/gitignore.sh ~/.gitignore
      assertFileExists ~/.gitignore "~/.gitignore set" "Failed to set ~/.gitignore"

      # Assign global gitignore in global gitconfig
      git config --global core.excludesfile ~/.gitignore

      # Set Github Username and email
      prompt "What is your Github Username (i.e. \"First Last\")?"
      git config --global user.name "$REPLY"
      success "Username set to $REPLY"
      prompt "What is your Github Email (i.e. \"me@mail.com\")?"
      success "Email set to $REPLY"
      git config --global user.email $REPLY
    else
      fail "Failed to configure Git because it is not installed"
    fi
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

      info "Opening Inconsolata Nerd Font Icons.otf"
      open "$(scriptDirectory)/fonts/'Inconsolata Nerd Font Icons.otf'"
      manualAction "Press Install Font Button for Inconsolata Nerd Font Icons.otf"
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
      "zshrc"
      "zprofile"
      "utility_aliases"
      "config_vars"
    )

    info "Backing up top-level dot files"

    # Backup Dot Files
    for dotFileName in "${topLevelDotFiles[@]}"; do
      backupFile ~/."$dotFileName" "$dotFileName"
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
    info "Backing up .vim folder"
    # Backup .vim folder
    backupDir ~/.vim vim

    # Set .vim folder
    info "Setting up .vim folder"
    rm -rf ~/.vim
    cp -r "$(scriptDirectory)/vim" ~/.vim
    assertDirectoryExists ~/.vim "~/.vim directory set" "Failed to set ~/.vim directory"

    # Backup .vimrc
    info "Backing up .vimrc"
    backupFile ~/.vimrc vimrc

    # Set .vimrc
    info "Setting up .vimrc"
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

    info "Cloning vim plugins"
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

    info "Configuring asdf version manager in .bash_profile and .zprofile"
    addLineToFiles "" ~/.bash_profile ~/.zprofile
    addLineToFiles "# asdf version manager" ~/.bash_profile ~/.zprofile
    addLineToFiles '. $HOME/.asdf/asdf.sh' ~/.bash_profile ~/.zprofile
    addLineToFiles '. $HOME/.asdf/completions/asdf.bash' ~/.bash_profile # This line does not apply to .zprofile
    success 'Added asdf configuration to ~/.bash_profile and ~/.zprofile'

    info "Adding Ruby Plugin..."
    asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
    info "Adding Postgres Plugin..."
    asdf plugin-add postgres
    info "Adding Node Plugin..."
    asdf plugin-add nodejs

    info "Backing up ~/.tool-versions"
    backupFile ~/.tool-versions tool-versions

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
  else
    # Skip this installation section
    info "Skipping..."
  fi

  # Set up homebrew
  promptNewSection "HOMEBREW PACKAGE MANAGER"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      info "Installing Homebrew package manager"
      if cmdExists ruby; then
        # Install Brew if it isn't already
        if cmdExists brew; then
          info "Homebrew is already installed"
        else
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        manualAction "If Homebrew installed successfully, please follow Homebrew's above instructions (in another tab) to add it to your path."
        source ~/.bash_profile

        # Test to ensure successful install
        assertPackageInstallation brew "homebrew"

        if cmdExists brew; then
          info "Updating homebrew"
          brew update
          info "Making homebrew healthy with brew doctor"
          brew doctor

          info "Adding Homebrew to \$PATH in .bash_profile and .zprofile"
          addLineToFiles "" ~/.bash_profile ~/.zprofile
          addLineToFiles "# Homebrew Package Manager" ~/.bash_profile ~/.zprofile
          addLineToFiles 'eval "$($(brew --prefix)/bin/brew shellenv)"' >> ~/.zprofile
          eval "$($(brew --prefix)/bin/brew shellenv)"
          success 'Added Homebrew to \$PATH in ~/.bash_profile and ~/.zprofile'
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
    if cmdExists brew; then
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
      # Install delta
      installPackage delta "brew install git-delta"
      assertPackageInstallation delta "delta (Better 'diff' Command)"
      # Install ytop
      installPackage ytop `brew tap cjbassi/ytop ; brew install ytop`
      assertPackageInstallation ytop "ytop (Better 'top' Command)"
      # Install htop
      installPackage htop "brew install htop"
      assertPackageInstallation htop "htop (Alternative 'top' Command)"
      # Install bat
      installPackage bat "brew install bat"
      assertPackageInstallation bat "bat (Better 'cat' Command)"
      # Install procs
      installPackage procs "brew install procs"
      assertPackageInstallation procs "procs (Better 'ps' Command)"
      # Install lsd
      installPackage lsd "brew install lsd"
      assertPackageInstallation lsd "lsd (Better 'ls' Command)"
      # Install icu4c
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
      if cmdExists brew; then
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

  # Get ZSH
  promptNewSection "INSTALL ZSH"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Can only install brew packages if brew is installed
    if cmdExists brew; then
      # Install zsh
      installPackage zsh "brew install zsh"
      assertPackageInstallation zsh "zsh"
      # TODO: Configure zsh
    else
      fail "Failed to install zsh. Homebrew is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi

  # Set up ZSH
  promptNewSection "SET UP ZSH"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup .oh-my-zsh folder
    info "Backing up .oh-my-zsh folder"
    backupDir ~/.oh-my-zsh oh-my-zsh

    # Set .oh-my-zsh folder
    info "Setting up .oh-my-zsh folder"
    rm -rf ~/.oh-my-zsh
    cp -r "$(scriptDirectory)/oh-my-zsh" ~/.oh-my-zsh
    assertDirectoryExists ~/.oh-my-zsh "~/.oh-my-zsh directory set" "Failed to set ~/.oh-my-zsh directory"

    # Clone all oh-my-zsh plugins
    zshPlugins=(
      "git://github.com/zsh-users/zsh-autosuggestions"
    )

    info "Cloning custom oh-my-zsh plugins"
    for pluginUrl in "${zshPlugins[@]}"; do
      repoName=$(repoName "$pluginUrl")
      cloneToPath=~/".oh-my-zsh/custom/plugins/$repoName"
      rm -rf "$cloneToPath"
      git clone "$pluginUrl" "$cloneToPath"
      # Invoke installation script if exists
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

  promptNewSection "CHANGE DEFAULT SHELL"
  info "Current default shell is: $(currShell)"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    PS3='   => Please enter the number corresponding to your shell choice: '
    options=()
    if cmdExists bash; then
      if [ $(currShell) != $(which bash) ]; then
        options+=("Bash")
      fi
    fi
    if cmdExists zsh; then
      if [ $(currShell) != $(which zsh) ]; then
        options+=("Zsh")
      fi
    fi
    if ! (( ${#options[@]} > 0 )); then
      warn "No other shells were found other than the current default. Skipping..."
    else
      options+=("Cancel / Keep Current Default")
      select opt in "${options[@]}"
      do
        case $opt in
          "Bash")
            chsh -s $(which bash)
            if [ $(currShell) == $(which bash) ]; then
              success "Default shell has been updated to bash"
            else
              fail "Failed to update default shell to bash"
            fi
            break
            ;;
          "Zsh")
            chsh -s $(which zsh)
            if [ $(currShell ) == $(which zsh) ]; then
              success "Default shell has been updated to zsh"
            else
              fail "Failed to update default shell to zsh"
            fi
            break
            ;;
          "Cancel / Keep Current Default")
            info "Keeping current default shell. Skipping..."
            break
            ;;
          *) warn "Invalid option $REPLY";;
          esac
      done
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
