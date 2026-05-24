#!/bin/bash

# Set up Git
function runSection {
  runPromptedSection "CONFIGURE GIT" setupGit
}

setupGit() {
  if cmdExists git; then
    local sshAgentEnv=""

    info "Configuring git"
    # Backup files
    backupFile ~/.gitconfig gitconfig

    # Set .gitconfig
    runCommand "Copy gitconfig" cp "$MACSETUP_CONFIG_DIR/git/gitconfig" ~/.gitconfig || return 1
    assertFileExists ~/.gitconfig "~/.gitconfig set" "Failed to set ~/.gitconfig"

    # Backup global .gitignore
    info "Backing up global .gitignore"
    backupFile ~/.gitignore gitignore

    # Set Global Gitignore
    info "Setting global .gitignore"
    runCommand "Copy global gitignore" cp "$MACSETUP_CONFIG_DIR"/dotfiles/mac/gitignore.sh ~/.gitignore || return 1
    assertFileExists ~/.gitignore "~/.gitignore set" "Failed to set ~/.gitignore"

    # Assign global gitignore in global gitconfig
    runCommand "Configure global git excludesfile" git config --global core.excludesfile ~/.gitignore || return 1

    # Set Github Username and email
    prompt "What is your Github User Name (i.e. \"First Last\")?"
    runCommand "Configure global git username" git config --global user.name "$REPLY" || return 1
    success "Username set to $REPLY"
    prompt "What is your Github Email (i.e. \"me@mail.com\")?"
    GIT_EMAIL="$REPLY"
    success "Email set to $GIT_EMAIL"
    runCommand "Configure global git email" git config --global user.email "$GIT_EMAIL" || return 1

    promptYesNo "Create an SSH Key For Email: $GIT_EMAIL?"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      SSH_CONFIG=~/.ssh/config
      if [ -f "$SSH_CONFIG" ]; then
        info "Found $SSH_CONFIG File"
      else
        info "Creating $SSH_CONFIG File..."
        runCommand "Create SSH config directory" mkdir -p ~/.ssh || return 1
        runCommand "Create SSH config file" touch "$SSH_CONFIG" || return 1
      fi

      DEAULT_KEY_NAME="git_key_ecdsa"
      prompt "What is the name of your key (Default: \"$DEAULT_KEY_NAME\")?"
      KEY_NAME="$REPLY"
      if [ -z "$KEY_NAME" ]; then
        info "Defaulting to key name: $DEAULT_KEY_NAME ..."
        KEY_NAME=$DEAULT_KEY_NAME
      fi
      KEY_PATH=~/.ssh/$KEY_NAME

      runInteractiveCommand "Create SSH key $KEY_PATH" ssh-keygen -f "$KEY_PATH" -t ed25519 -C "$GIT_EMAIL" || return 1
      assertFileExists "$KEY_PATH" "Successfully created SSH Key: $KEY_PATH" "Failed to create SSH Key: $KEY_PATH"

      info "Starting ssh-agent in background"
      runCommandOutputVariable sshAgentEnv "Start ssh-agent" ssh-agent -s || return 1
      eval "$sshAgentEnv"
      echo

      # Preserve white space by changing the Internal Field Separator
      IFS='%'
      addLineToFiles "" "$SSH_CONFIG"
      addLineToFiles "# Git SSH" "$SSH_CONFIG"
      addLineToFiles "Host *" "$SSH_CONFIG"
      addLineToFiles "  AddKeysToAgent yes" "$SSH_CONFIG"
      addLineToFiles "  UseKeychain yes" "$SSH_CONFIG"
      addLineToFiles "  IdentityFile $KEY_PATH" "$SSH_CONFIG"
      # Reset the Internal Field Separator
      unset IFS

      assertFileExists "$SSH_CONFIG" "Added entry to SSH Config For Key: $KEY_PATH" "$SSH_CONFIG not found, cannot add SSH key to SSH Config"

      manualAction "If desired, add your new key to Github follwing:\n\thttps://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
    fi
  else
    fail "Failed to configure Git because it is not installed"
  fi
}
