#!/bin/bash

# Change default shell
function runSection {
  runPromptedSection "CHANGE DEFAULT SHELL" changeDefaultShell
}

changeDefaultShell() {
  info "Current default shell is: $(currShell)"
  PS3='   => Please enter the number corresponding to your shell choice: '
  options=()
  if cmdExists bash; then
    if [ "$(currShell)" != "$(which bash)" ]; then
      options+=("Bash")
    fi
  fi
  if cmdExists zsh; then
    if [ "$(currShell)" != "$(which zsh)" ]; then
      options+=("Zsh")
    fi
  fi
  if ! (( ${#options[@]} > 0 )); then
    warn "No other shells were found other than the current default. Skipping..."
  else
    options+=("Cancel / Keep Current Default")
    chooseOption "Choose Default Shell:" "${options[@]}"
    case "$MACSETUP_UI_CHOICE" in
      "Bash")
        runInteractiveCommand "Change default shell to bash" chsh -s "$(which bash)" || return 1
        if [ "$(currShell)" == "$(which bash)" ]; then
          success "Default shell has been updated to bash"
        else
          fail "Failed to update default shell to bash"
        fi
        ;;
      "Zsh")
        runInteractiveCommand "Change default shell to zsh" chsh -s "$(which zsh)" || return 1
        if [ "$(currShell)" == "$(which zsh)" ]; then
          success "Default shell has been updated to zsh"
        else
          fail "Failed to update default shell to zsh"
        fi
        ;;
      "Cancel / Keep Current Default")
        info "Keeping current default shell. Skipping..."
        ;;
    esac
  fi
}
