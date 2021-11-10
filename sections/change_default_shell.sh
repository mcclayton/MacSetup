#!/bin/bash

# Change default shell
function runSection {
promptNewSection "CHANGE DEFAULT SHELL"
  info "Current default shell is: $(currShell)"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    PS3='   => Please enter the number corresponding to your shell choice: '
    options=()
    if cmdExists bash; then
      if [ $(currShell) != $(which bash) ]; then
        options+=("Bash")
      fi
    fi
    if cmdExists zsh; then
      if [ $(currShell) != $(which zsh) ]; then
        options+=("Zsh")
      fi
    fi
    if ! (( ${#options[@]} > 0 )); then
      warn "No other shells were found other than the current default. Skipping..."
    else
      options+=("Cancel / Keep Current Default")
      select opt in "${options[@]}"
      do
        case $opt in
          "Bash")
            chsh -s $(which bash)
            if [ $(currShell) == $(which bash) ]; then
              success "Default shell has been updated to bash"
            else
              fail "Failed to update default shell to bash"
            fi
            break
            ;;
          "Zsh")
            chsh -s $(which zsh)
            if [ $(currShell ) == $(which zsh) ]; then
              success "Default shell has been updated to zsh"
            else
              fail "Failed to update default shell to zsh"
            fi
            break
            ;;
          "Cancel / Keep Current Default")
            info "Keeping current default shell. Skipping..."
            break
            ;;
          *) warn "Invalid option $REPLY";;
          esac
      done
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
