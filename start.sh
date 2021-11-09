#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

# Bring in constants
source "$(scriptDirectory)/installation/constants.sh"
# Bring in the helper functions
source "$(scriptDirectory)/installation/helperFunctions.sh"

sandboxInstall() {
  if cmdExists docker; then
    info "Setting up dockerized sandbox environment..."
    docker build -t macsetup .
    success "Built docker image for sandbox environment."
    info "Starting sandbox environment..."
    docker container run --rm -it -h sandbox macsetup /bin/bash -c "./install.sh"
  else
    fail "Failed to run in Sandbox mode. Docker cli is not installed."
  fi
}

function machineInstall() {
  info "Using current machine environment..."
  ./install.sh
}

### Main ###
PS3='   => Choose Execution Environment: '
options=("Sandbox (Docker)" "Current Machine" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Sandbox (Docker)")
            sandboxInstall
            break
            ;;
        "Current Machine")
            machineInstall
            break
            ;;
        "Quit")
            break
            ;;
        *) warn "Invalid option $REPLY";;
    esac
done
