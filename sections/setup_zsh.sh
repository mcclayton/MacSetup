#!/bin/bash

# Set up ZSH
function runSection {
  runPromptedSection "SET UP ZSH" setupZsh
}

setupZsh() {
  # Backup .oh-my-zsh folder
  info "Backing up .oh-my-zsh folder"
  backupDir ~/.oh-my-zsh oh-my-zsh

  # Set .oh-my-zsh folder
  info "Setting up .oh-my-zsh folder"
  runCommand "Remove existing ~/.oh-my-zsh directory" rm -rf ~/.oh-my-zsh || return 1

  # Clone oh-my-zsh
  ZSH=${ZSH:-~/.oh-my-zsh}
  REPO=${REPO:-ohmyzsh/ohmyzsh}
  REMOTE=${REMOTE:-https://github.com/${REPO}.git}
  BRANCH=${BRANCH:-master}

  runCommand "Clone oh-my-zsh repo" git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    -c oh-my-zsh.remote=origin \
    -c oh-my-zsh.branch="$BRANCH" \
    --depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH" || return 1

  assertDirectoryExists ~/.oh-my-zsh "~/.oh-my-zsh directory set" "Failed to set ~/.oh-my-zsh directory"

  # Clone all oh-my-zsh plugins
  zshPlugins=(
    "git://github.com/zsh-users/zsh-autosuggestions"
  )

  info "Cloning custom oh-my-zsh plugins"
  for pluginUrl in "${zshPlugins[@]}"; do
    repoName=$(repoName "$pluginUrl")
    cloneToPath=~/".oh-my-zsh/custom/plugins/$repoName"
    runCommand "Remove existing oh-my-zsh plugin $repoName" rm -rf "$cloneToPath" || continue
    runCommand "Clone oh-my-zsh plugin $repoName" git clone "$pluginUrl" "$cloneToPath" || continue
    # Invoke installation script if exists
    installPath="$cloneToPath/install"
    if [ -f "$installPath" ]; then
      echo -e "\n\nInvoking installation for $repoName\n"
      runInteractiveCommand "Run oh-my-zsh plugin installer for $repoName" "$installPath" || continue
    fi
    assertDirectoryExists "$cloneToPath" "$repoName plugin added to $cloneToPath" "Failed to add plugin $repoName to $cloneToPath"
  done
}
