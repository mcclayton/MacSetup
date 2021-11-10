#!/bin/bash

# Set up ZSH
function runSection {
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
}
