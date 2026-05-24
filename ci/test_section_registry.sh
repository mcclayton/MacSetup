#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

echo "Checking section registry metadata..."
TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  sectionRegistryLoad

  test "${#MACSETUP_SECTION_PATHS[@]}" -eq 19
  test "${#MACSETUP_SECTION_TITLES[@]}" -eq 19
  test "${#MACSETUP_SECTION_PLATFORMS[@]}" -eq 19
  test "$(sectionPathForIndex 0)" = "install_xcode_and_git"
  test "$(sectionTitleForIndex 0)" = "XCODE COMMAND LINE TOOLS + GIT"
  test "$(sectionPlatformForIndex 0)" = "mac"
  test "$(sectionPlatformReason mac)" = "Mac only"
  test "$(sectionPlatformReason all)" = ""

  for section_path in "${MACSETUP_SECTION_PATHS[@]}"; do
    test -f "./sections/$section_path.sh"
  done
'

echo "Checking prompted section wrapper run path..."
tmp_home="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT

printf 'y\n' | HOME="$tmp_home" MACSETUP_UI=plain TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  sectionBody() {
    echo ran > "$HOME/section-ran"
  }

  runPromptedSection "TEST SECTION" sectionBody
  test -f "$HOME/section-ran"
'

echo "Checking prompted section wrapper skip path..."
printf 'n\n' | HOME="$tmp_home" MACSETUP_UI=plain TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  sectionBody() {
    echo ran > "$HOME/section-skipped"
  }

  runPromptedSection "TEST SECTION" sectionBody
  test ! -f "$HOME/section-skipped"
'
