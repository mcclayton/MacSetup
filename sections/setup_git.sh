#!/bin/bash

# Set up Git
function runSection {
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
}
