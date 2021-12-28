#!/bin/bash

# Set up homebrew
function runSection {
  promptNewSection "HOMEBREW PACKAGE MANAGER"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      info "Installing Homebrew package manager"
      # Install Brew if it isn't already
      if cmdExists brew; then
        info "Homebrew is already installed"
      else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi

      # Attempt to find brew prefix automatically
      prefixes=(
        "/usr/local"
        "/opt/homebrew"
        "/home/linuxbrew/.linuxbrew"
      )
      for prefix in "${prefixes[@]}"; do
        BREW_PATH=$prefix/bin/brew
        if [ -f $BREW_PATH ]; then
          info "Loading brew into current context..."
          eval "$($($BREW_PATH --prefix)/bin/brew shellenv)"
        fi
      done

      if cmdExists brew; then
        info "Brew loaded into current context"
      else
        warn "Brew was not loaded into current context, falling back to manual setup"
        if [ "$SANDBOX" = true ]; then
          SEPARATOR="    |"
          echo -e "If Homebrew installed successfully, please follow Homebrew's above instructions (in another tab) to add it to your path."
          echo -e "${SEPARATOR} [SANDBOX] To open the sandbox in another tab"
          echo -e "${SEPARATOR} - Exec Into the current sandox using the command:"
          echo -e "${SEPARATOR} \`docker exec -it macsetup /bin/bash\`"
          manualAction "Follow the steps above to ensure Homebrew is loaded into the environment."
        else
          manualAction "If Homebrew installed successfully, please follow Homebrew's above instructions (in another tab) to add it to your path."
        fi
      fi

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
        addLineToFiles 'eval "$($(brew --prefix)/bin/brew shellenv)"' ~/.bash_profile ~/.zprofile
        eval "$($(brew --prefix)/bin/brew shellenv)"
        success 'Added Homebrew to $PATH in ~/.bash_profile and ~/.zprofile'
      else
        fail "Failed to update Homebrew because it is not installed"
      fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
