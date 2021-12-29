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

    ZSH=${ZSH:-~/.oh-my-zsh}
    REPO=${REPO:-ohmyzsh/ohmyzsh}
    REMOTE=${REMOTE:-https://github.com/${REPO}.git}
    BRANCH=${BRANCH:-master}

    git clone -c core.eol=lf -c core.autocrlf=false \
      -c fsck.zeroPaddedFilemode=ignore \
      -c fetch.fsck.zeroPaddedFilemode=ignore \
      -c receive.fsck.zeroPaddedFilemode=ignore \
      -c oh-my-zsh.remote=origin \
      -c oh-my-zsh.branch="$BRANCH" \
      --depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH" || {
      fail "Failed to clone oh-my-zsh repo"
    }

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
