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
find start.sh install.sh clean.sh diff.sh sections lib config assets ci -name '*.sh' -type f -print0 \
  | xargs -0 bash -n

echo "Checking start.sh quit path..."
printf '3\n' | ./start.sh

echo "Checking UI prompt behavior..."
bash ./ci/test_ui.sh

echo "Checking PATH helper behavior..."
bash ./ci/test_path_helpers.sh

echo "Checking terminal compatibility behavior..."
bash ./ci/test_terminal_compat.sh

echo "Checking platform-specific Git config behavior..."
bash ./ci/test_setup_git_platform.sh

echo "Checking asdf tool version pins..."
bash ./ci/test_tool_versions.sh

echo "Checking install.sh skipped-section path with isolated HOME..."
tmp_home="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT
no_prompts | env HOME="$tmp_home" TERM="${TERM:-xterm}" ./install.sh

echo "Checking focused package configuration behavior..."
./ci/test_configure_bat.sh
./ci/test_configure_ghostty.sh
