#!/bin/bash

set -euo pipefail

profile="${1:?Usage: ci/docker_install_smoke.sh <profile> <base-image>}"
base_image="${2:?Usage: ci/docker_install_smoke.sh <profile> <base-image>}"
image_tag="macsetup:${profile}"

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

no_prompts() {
  for _ in {1..32}; do
    printf 'n\n'
  done
}

docker build \
  --build-arg BASE_IMAGE="$base_image" \
  --build-arg SANDBOX_PROFILE="$profile" \
  -t "$image_tag" .

no_prompts | docker container run \
  --rm \
  -i \
  --env TERM="${TERM:-xterm}" \
  --env MACSETUP_SANDBOX_PROFILE="$profile" \
  "$image_tag" \
  ./install.sh
