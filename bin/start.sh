#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
  echo "$self_dir"
}

REPO_ROOT="$(scriptDirectory)"
cd "$REPO_ROOT"

# Bring in constants
source "$REPO_ROOT/lib/macsetup/constants.sh"
# Bring in the helper functions
source "$REPO_ROOT/lib/macsetup/helperFunctions.sh"

sandboxInstallWithProfile() {
  local profile="$1"
  local baseImage="$2"
  local imageTag="$3"
  local containerName="macsetup-${profile}-$$"
  local forceRoundedUi=false

  info "Setting up dockerized sandbox environment: ${profile}"
  info "Docker base image: ${baseImage}"
  if ! docker build \
    --label "$MACSETUP_DOCKER_LABEL" \
    --build-arg BASE_IMAGE="$baseImage" \
    --build-arg SANDBOX_PROFILE="$profile" \
    -t "$imageTag" .; then
    fail "Failed to build docker image for sandbox environment: ${imageTag}"
    return 1
  fi

  success "Built docker image for sandbox environment: ${imageTag}"
  info "Starting sandbox environment..."

  local dockerRunFlags=("-i")
  if [ -t 0 ] && [ -t 1 ]; then
    dockerRunFlags=("-it")
  fi

  if uiSupportsRoundedBoxes; then
    forceRoundedUi=true
  fi

  # Need to forward env vars so the sandbox can report its terminal/profile.
  if ! docker container run \
    --label "$MACSETUP_DOCKER_LABEL" \
    --env TERM \
    --env TERM_PROGRAM \
    --env LANG \
    --env LC_ALL \
    --env LC_CTYPE \
    --env MACSETUP_UI_FORCE_ROUNDED="$forceRoundedUi" \
    --env MACSETUP_SANDBOX_PROFILE="$profile" \
    --name "$containerName" \
    --rm \
    "${dockerRunFlags[@]}" \
    -h sandbox \
    "$imageTag" \
    /bin/bash -c 'echo "Sandbox profile: ${MACSETUP_SANDBOX_PROFILE:-unknown}"; vim --version | sed -n "1p"; if command -v node >/dev/null 2>&1; then node --version; else echo "node: unavailable"; fi; ./install.sh'; then
    fail "Sandbox environment failed: ${imageTag}"
    return 1
  fi
}

sandboxInstall() {
  if cmdExists docker; then
    local sandboxOptions=("Old Vim compatibility (Ubuntu 18.04 / Vim 8.0)" "Modern Vim + Coc (Node 22 / Vim 9)" "Back")
    chooseOption "Choose Sandbox Vim Profile:" "${sandboxOptions[@]}"
    case "$MACSETUP_UI_CHOICE" in
      "Old Vim compatibility (Ubuntu 18.04 / Vim 8.0)")
        sandboxInstallWithProfile "vim-old" "ubuntu:18.04" "macsetup:vim-old"
        ;;
      "Modern Vim + Coc (Node 22 / Vim 9)")
        sandboxInstallWithProfile "vim-modern" "node:22-bookworm" "macsetup:vim-modern"
        ;;
      "Back")
        ;;
    esac
  else
    fail "Failed to run in Sandbox mode. Docker cli is not installed."
  fi
}

function machineInstall() {
  info "Using current machine environment..."
  "$REPO_ROOT/install.sh"
}

### Main ###
options=("Sandbox (Docker)" "Current Machine" "Quit")
chooseOption "Choose Execution Environment:" "${options[@]}"
case "$MACSETUP_UI_CHOICE" in
  "Sandbox (Docker)")
    sandboxInstall
    ;;
  "Current Machine")
    machineInstall
    ;;
  "Quit")
    ;;
esac
