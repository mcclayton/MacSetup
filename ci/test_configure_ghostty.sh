#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
tmp_apps="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home" "$tmp_apps"
}
trap cleanup EXIT

mkdir -p "$tmp_apps/Ghostty.app"

HOME="$tmp_home" MACSETUP_APPLICATIONS_DIR="$tmp_apps" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh
  source ./lib/macsetup/appConfigUtil.sh

  old_config="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  mkdir -p "$(dirname "$old_config")"
  printf "%s\n" "old ghostty config" > "$old_config"

  configureGhostty

  test "${#FAILURES_ARRAY[@]}" -eq 0
  cmp -s "$MACSETUP_CONFIG_DIR/terminal/ghostty/config" "$old_config"
  find "$HOME/.mac_setup/backups" -type f -name config | grep -q .
'
