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
source "$MACSETUP_LIB_DIR/helperFunctions.sh"

info "Pruning docker resources with label: '$MACSETUP_DOCKER_LABEL'..."
docker system prune --filter "$MACSETUP_DOCKER_LABEL_FILTER" --force
