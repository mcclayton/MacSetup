#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

export HOME="$tmp_root/home"
export MACSETUP_APPLICATIONS_DIR="$tmp_root/Applications With Spaces"
mkdir -p "$HOME" "$MACSETUP_APPLICATIONS_DIR"

source ./lib/macsetup/constants.sh
source ./lib/macsetup/helperFunctions.sh
source ./lib/macsetup/appConfigUtil.sh
source ./sections/install_applications.sh

echo "Checking DisplayLink missing-app failure..."
if configureDisplayLink > "$tmp_root/missing-output"; then
  echo "DisplayLink setup unexpectedly succeeded without an installed app" >&2
  exit 1
fi
grep -q "Cannot configure DisplayLink Manager" "$tmp_root/missing-output"
test "${#FAILURES_ARRAY[@]}" -eq 1
if grep -q "MANUAL ACTION REQUIRED" "$tmp_root/missing-output"; then
  echo "DisplayLink setup prompted for permissions before installation" >&2
  exit 1
fi
FAILURES_ARRAY=()

# Exercise the real Applications section, cask helper, and manual-action prompt.
# Only Homebrew, the platform check, selection, and host app assertion are mocked.
promptNewSection() { REPLY=y; }
promptYesNo() {
  REPLY=n
  if [ "$1" = "Install application DisplayLink Manager.app?" ]; then
    REPLY=y
  fi
}
isMacOs() { return 0; }
brew() {
  printf '%s\n' "$*" >> "$tmp_root/brew-calls"
  case "$*" in
    "ls --cask --versions displaylink") return 1 ;;
    "install --cask displaylink")
      mkdir -p "$MACSETUP_APPLICATIONS_DIR/DisplayLink Manager.app"
      ;;
    "cleanup") return 0 ;;
    *) echo "Unexpected Homebrew call: $*" >&2; return 1 ;;
  esac
}
assertAppInstallation() {
  test "$1" = "DisplayLink Manager.app"
  test -d "$MACSETUP_APPLICATIONS_DIR/$1"
}

echo "Checking DisplayLink fresh-install flow and permission handoff..."
runSection <<< '' > "$tmp_root/install-output"
test "${#FAILURES_ARRAY[@]}" -eq 0
grep -qx "install --cask displaylink" "$tmp_root/brew-calls"
grep -q "MANUAL ACTION REQUIRED" "$tmp_root/install-output"
grep -q "Screen Recording" "$tmp_root/install-output"
grep -q "background activity" "$tmp_root/install-output"
grep -q "automatic launch at login" "$tmp_root/install-output"
grep -q "verify your external displays work" "$tmp_root/install-output"

echo "Checking DisplayLink rerun without overwrite..."
brew() {
  case "$*" in
    "ls --cask --versions displaylink"|"cleanup") return 0 ;;
    *) echo "Unexpected Homebrew mutation on rerun: $*" >&2; return 1 ;;
  esac
}
runSection < /dev/null > "$tmp_root/rerun-output"
grep -q "Skipping overwrite" "$tmp_root/rerun-output"
if grep -q "MANUAL ACTION REQUIRED" "$tmp_root/rerun-output"; then
  echo "DisplayLink setup ran despite declining overwrite" >&2
  exit 1
fi
test -d "$MACSETUP_APPLICATIONS_DIR/DisplayLink Manager.app"
test "${#FAILURES_ARRAY[@]}" -eq 0

echo "DisplayLink installer checks passed."
