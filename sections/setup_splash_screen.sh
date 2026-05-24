#!/bin/bash

# Set up terminal splash screem
function runSection {
  runPromptedSection "SETTING UP SPLASH SCREEN" setupSplashScreen
}

setupSplashScreen() {
  if [ -f ~/.bashrc ] && grep -q "local SPLASH_COMMAND=" ~/.bashrc && grep -q "source ~/.splash_screens" ~/.bashrc; then
    options=("Party Horse" "Wolf" "Charizard" "Initials" "No Splash Screen" "Cancel" )
    chooseOption "Choose Terminal Splash Screen:" "${options[@]}"
    case "$MACSETUP_UI_CHOICE" in
      "Party Horse")
        COMMAND_CHOICE="party_horse"
        ;;
      "Wolf")
        COMMAND_CHOICE="wolf"
        ;;
      "Charizard")
        COMMAND_CHOICE="charizard"
        ;;
      "Initials")
        runCommand "Copy splash screen logo" cp "$MACSETUP_ASSETS_DIR/splash/mcc_logo.png" ~/mcc_logo.png || return 1
        assertFileExists ~/mcc_logo.png "Copied over mcc_logo.png asset" "Failed to copy over mcc_logo.png asset"
        COMMAND_CHOICE="mcc"
        ;;
      "No Splash Screen")
        info "No splash screen set"
        COMMAND_CHOICE=
        ;;
      "Cancel")
        COMMAND_CHOICE='cancel'
        ;;
    esac

    if [ "$COMMAND_CHOICE" == "cancel" ]; then
      info "Cancelling splash screen setup..."
    else
      info "Setting splash screen to use command '$COMMAND_CHOICE'"
      runCommand "Update splash screen command" sed -i -e "s/local SPLASH_COMMAND=.*/local SPLASH_COMMAND=$COMMAND_CHOICE/" ~/.bashrc || return 1

      if grep -q "local SPLASH_COMMAND=$COMMAND_CHOICE" ~/.bashrc; then
        success "Splash screen set to use command '$COMMAND_CHOICE'"
      else
        fail "Failed to set the splash screen to use command '$COMMAND_CHOICE'"
      fi
    fi
  else
    fail "~/.bashrc is not set up to support splash screens. Please ensure the 'TOP-LEVEL DOT FILES' setup step ran successfully."
  fi
}
