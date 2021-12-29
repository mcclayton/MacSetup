#!/bin/bash

# Set new top-level dot files
function runSection {
  promptNewSection "SETTING UP SPLASH SCREEN"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f ~/.bashrc ] && grep -q "local SPLASH_COMMAND=" ~/.bashrc && grep -q "source ~/.splash_screens" ~/.bashrc; then
      PS3='   => Choose Terminal Splash Screen: '
      options=("Party Horse" "Wolf" "Initials" "Cancel / No Splash Screen")
      select opt in "${options[@]}"
      do
        case $opt in
          "Party Horse")
            COMMAND_CHOICE="party_horse"
            break
            ;;
          "Wolf")
            COMMAND_CHOICE="wolf"
            break
            ;;
          "Initials")
            cp "$(scriptDirectory)/splash_screen/mcc_logo.png" ~/mcc_logo.png
            assertFileExists ~/mcc_logo.png "Copied over mcc_logo.png asset" "Failed to copy over mcc_logo.png asset"
            COMMAND_CHOICE="mcc"
            break
            ;;
          "Cancel / No Splash Screen")
            info "No splash screen set"
            COMMAND_CHOICE=noop
            break
            ;;
          *) warn "Invalid option $REPLY";;
          esac
      done

      info "Setting splash screen to use command '$COMMAND_CHOICE'"
      sed -i -e "s/local SPLASH_COMMAND=.*/local SPLASH_COMMAND=$COMMAND_CHOICE/" ~/.bashrc

      if grep -q "local SPLASH_COMMAND=$COMMAND_CHOICE" ~/.bashrc; then
        success "Splash screen set to use command '$COMMAND_CHOICE'"
      else
        fail "Failed to set the splash screen to use command '$COMMAND_CHOICE'"
      fi
    else
      fail "~/.bashrc is not set up to support splash screens. Please ensure the 'TOP-LEVEL DOT FILES' setup step ran successfully."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}