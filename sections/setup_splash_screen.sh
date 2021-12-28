#!/bin/bash

# Set new top-level dot files
function runSection {
promptNewSection "SETTING UP SPLASH SCREEN"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$(scriptDirectory)/splash_screen/mcc_logo.png" ~/mcc_logo.png
    # TODO
    # assertFileExists $ROOT_MAC_SETUP_FOLDER/mcc_logo.png

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
    # Skip this installation section
    info "Skipping..."
  fi
}
