#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT

echo "Checking idempotent line insertion..."
HOME="$tmp_home" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  target="$HOME/profile"
  addLineToFiles "# Tooling" "$target"
  addLineToFiles "# Tooling" "$target"
  addLineToFiles "export PATH=\"/opt/tool:\$PATH\"" "$target"
  addLineToFiles "export PATH=\"/opt/tool:\$PATH\"" "$target"
  addLineToFiles "" "$target"
  addLineToFiles "" "$target"

  test "$(grep -cFx "# Tooling (Added by MacSetup)" "$target")" -eq 1
  test "$(grep -cFx "export PATH=\"/opt/tool:\$PATH\"" "$target")" -eq 1
  ! grep -q "^$" "$target"
'

echo "Checking managed block replacement..."
HOME="$tmp_home" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  target="$HOME/block-file"
  printf "%s\n" "before" > "$target"
  ensureManagedBlock "Example" "$target" "one" "two"
  ensureManagedBlock "Example" "$target" "one" "three"
  printf "%s\n" "after" >> "$target"

  test "$(grep -cFx "# >>> MacSetup: Example" "$target")" -eq 1
  test "$(grep -cFx "# <<< MacSetup: Example" "$target")" -eq 1
  grep -qFx "one" "$target"
  grep -qFx "three" "$target"
  ! grep -qFx "two" "$target"
  grep -qFx "before" "$target"
  grep -qFx "after" "$target"
'
