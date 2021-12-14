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
      prompt "What is your Github User Name (i.e. \"First Last\")?"
      git config --global user.name "$REPLY"
      success "Username set to $REPLY"
      prompt "What is your Github Email (i.e. \"me@mail.com\")?"
      GIT_EMAIL="$REPLY"
      success "Email set to $GIT_EMAIL"
      git config --global user.email $GIT_EMAIL

      promptYesNo "Create an SSH Key For Email: $GIT_EMAIL?"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        SSH_CONFIG=~/.ssh/config
        if [ -f $SSH_CONFIG ]; then
          info "Found $SSH_CONFIG File"
        else
          info "Creating $SSH_CONFIG File..."
          mkdir -p ~/.ssh
          touch $SSH_CONFIG
        fi

        DEAULT_KEY_NAME="git_key_ecdsa"
        prompt "What is the name of your key (Default: \"$DEAULT_KEY_NAME\")?"
        KEY_NAME="$REPLY"
        if [ -z "$KEY_NAME" ]; then
          info "Defaulting to key name: $DEAULT_KEY_NAME ..."
          KEY_NAME=$DEAULT_KEY_NAME
        fi
        KEY_PATH=~/.ssh/$KEY_NAME

        ssh-keygen -f $KEY_PATH -t ed25519 -C "$GIT_EMAIL"
        assertFileExists $KEY_PATH "Successfully created SSH Key: $KEY_PATH" "Failed to create SSH Key: $KEY_PATH"

        info "Starting ssh-agent in background"
        eval "$(ssh-agent -s)"
        echo

        # Preserve white space by changing the Internal Field Separator
        IFS='%'
        addLineToFiles "" $SSH_CONFIG
        addLineToFiles "# Git SSH" $SSH_CONFIG
        addLineToFiles "Host *" $SSH_CONFIG
        addLineToFiles "  AddKeysToAgent yes" $SSH_CONFIG
        addLineToFiles "  UseKeychain yes" $SSH_CONFIG
        addLineToFiles "  IdentityFile $KEY_PATH" $SSH_CONFIG
        # Reset the Internal Field Separator
        unset IFS

        assertFileExists $SSH_CONFIG "Added entry to SSH Config For Key: $KEY_PATH" "$SSH_CONFIG not found, cannot add SSH key to SSH Config"

        manualAction "If desired, add your new key to Github follwing:\n\thttps://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
      fi
    else
      fail "Failed to configure Git because it is not installed"
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
