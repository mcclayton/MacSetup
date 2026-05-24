#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

no_prompts() {
  for _ in {1..32}; do
    printf 'n\n'
  done
}

echo "Checking shell syntax..."
find start.sh install.sh clean.sh sections lib config assets ci tools -name '*.sh' -type f -print0 \
  | xargs -0 bash -n

echo "Checking start.sh quit path..."
printf '3\n' | ./start.sh

echo "Checking UI prompt behavior..."
bash ./ci/test_ui.sh

echo "Checking shell startup helpers..."
bash ./ci/test_shell_startup.sh

echo "Checking command failure logging..."
bash ./ci/test_command_logging.sh

echo "Checking install.sh skipped-section path with isolated HOME..."
tmp_home="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT
no_prompts | env HOME="$tmp_home" TERM="${TERM:-xterm}" ./install.sh

echo "Checking focused package configuration behavior..."
./ci/test_configure_bat.sh

echo "Checking idempotent file edit helpers..."
./ci/test_file_edits.sh

echo "Checking installer helpers..."
./ci/test_installers.sh

echo "Checking section registry and prompt wrapper..."
./ci/test_section_registry.sh
