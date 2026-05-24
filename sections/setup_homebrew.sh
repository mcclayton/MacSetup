#!/bin/bash

# Set up homebrew
function runSection {
  runPromptedSection "HOMEBREW PACKAGE MANAGER" setupHomebrew
}

setupHomebrew() {
  local brewInstaller=""
  local brewShellenv=""
  local brewPrefix=""
  local prefix=""
  local BREW_PATH=""

  info "Installing Homebrew package manager"
  # Install Brew if it isn't already
  if cmdExists brew; then
    info "Homebrew is already installed"
  else
    brewInstaller="$(mktemp "${TMPDIR:-/tmp}/macsetup-homebrew-install.XXXXXX")" || {
      fail "Failed to create temporary file for Homebrew installer"
      return 1
    }
    runCommand "Download Homebrew installer" curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$brewInstaller" || {
      rm -f "$brewInstaller"
      return 1
    }
    runInteractiveCommand "Run Homebrew installer" /bin/bash "$brewInstaller" || {
      rm -f "$brewInstaller"
      return 1
    }
    rm -f "$brewInstaller"
  fi

  # Attempt to find brew prefix automatically
  local prefixes=(
    "/usr/local"
    "/opt/homebrew"
    "/home/linuxbrew/.linuxbrew"
  )
  for prefix in "${prefixes[@]}"; do
    BREW_PATH=$prefix/bin/brew
    if [ -f "$BREW_PATH" ]; then
      info "Loading brew into current context..."
      if runProbeCommandOutputVariable brewShellenv "Probe Homebrew shellenv from $BREW_PATH" "$BREW_PATH" shellenv; then
        eval "$brewShellenv"
      fi
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
    runCommand "Update Homebrew" brew update || return 1
    info "Making homebrew healthy with brew doctor"
    runOptionalCommand "Run brew doctor" brew doctor || true

    info 'Adding Homebrew to $PATH in .bash_profile and .zprofile'
    runCommandOutputVariable brewPrefix "Find Homebrew prefix" brew --prefix || return 1
    addLineToFiles "" ~/.bash_profile ~/.zprofile
    addLineToFiles "# Homebrew Package Manager" ~/.bash_profile ~/.zprofile
    addLineToFiles "eval \"\$($brewPrefix/bin/brew shellenv)\"" ~/.bash_profile ~/.zprofile
    runCommandOutputVariable brewShellenv "Load Homebrew shellenv" "$brewPrefix/bin/brew" shellenv || return 1
    eval "$brewShellenv"
    success 'Added Homebrew to $PATH in ~/.bash_profile and ~/.zprofile'
  else
    fail "Failed to update Homebrew because it is not installed"
  fi
}
