#!/bin/bash

# Install Homebrew packages
function runSection {
  promptNewSection "HOMEBREW PACKAGES"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Can only install brew packages if brew is installed
    if cmdExists brew; then
      # Install lolcat
      installPackage lolcat "brew install lolcat"
      assertPackageInstallation lolcat "lolcat"
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
      # Install viu
      installPackage viu "brew install viu"
      assertPackageInstallation viu "viu"
      # Install yarn
      installPackage yarn "brew install yarn"
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
      # Install openssl
      installPackage openssl "brew install openssl"
      assertPackageInstallation openssl "openssl"
      # Install icu4c
      installPackage icu4c "brew install icu4c" configureICU4C
      assertPackageInstallation icuinfo "icu4c"
      # Install gcc
      installPackage gcc "brew install gcc"
      assertPackageInstallation gcc "gcc"
    else
      fail "Failed to install brew packages. Homebrew is not installed."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
