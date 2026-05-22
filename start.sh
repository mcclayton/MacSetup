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

sandboxInstallWithProfile() {
  local profile="$1"
  local baseImage="$2"
  local imageTag="$3"
  local containerName="macsetup-${profile}"

  info "Setting up dockerized sandbox environment: ${profile}"
  info "Docker base image: ${baseImage}"
  docker build \
    --build-arg BASE_IMAGE="$baseImage" \
    --build-arg SANDBOX_PROFILE="$profile" \
    -t "$imageTag" .
  success "Built docker image for sandbox environment: ${imageTag}"
  info "Starting sandbox environment..."
  # Need to forward env vars so the sandbox can report its terminal/profile.
  docker container run \
    --env TERM \
    --env TERM_PROGRAM \
    --env MACSETUP_SANDBOX_PROFILE="$profile" \
    --name "$containerName" \
    --rm \
    -it \
    -h sandbox \
    "$imageTag" \
    /bin/bash -c 'echo "Sandbox profile: ${MACSETUP_SANDBOX_PROFILE:-unknown}"; vim --version | sed -n "1p"; if command -v node >/dev/null 2>&1; then node --version; else echo "node: unavailable"; fi; ./install.sh'
}

sandboxInstall() {
  if cmdExists docker; then
    local sandboxPs3="$PS3"
    PS3='   => Choose Sandbox Vim Profile: '
    local sandboxOptions=("Old Vim compatibility (Ubuntu 18.04 / Vim 8.0)" "Modern Vim + Coc (Node 22 / Vim 9)" "Back")
    select sandboxOpt in "${sandboxOptions[@]}"
    do
      case $sandboxOpt in
        "Old Vim compatibility (Ubuntu 18.04 / Vim 8.0)")
          PS3="$sandboxPs3"
          sandboxInstallWithProfile "vim-old" "ubuntu:18.04" "macsetup:vim-old"
          break
          ;;
        "Modern Vim + Coc (Node 22 / Vim 9)")
          PS3="$sandboxPs3"
          sandboxInstallWithProfile "vim-modern" "node:22-bookworm" "macsetup:vim-modern"
          break
          ;;
        "Back")
          PS3="$sandboxPs3"
          break
          ;;
        *) warn "Invalid option $REPLY";;
      esac
    done
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
