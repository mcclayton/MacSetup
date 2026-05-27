#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

if [ -z "${TERM:-}" ] || [ "$TERM" = "dumb" ]; then
  export TERM="xterm"
fi

source ./lib/macsetup/constants.sh
source ./lib/macsetup/helperFunctions.sh

die() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assertEquals() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$actual" != "$expected" ]; then
    printf 'FAIL: %s\nExpected: %s\nActual:   %s\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

assertPathCount() {
  local path_entry="$1"
  local expected_count="$2"
  local message="$3"

  assertEquals "$expected_count" "$(countPathEntry "$path_entry")" "$message"
}

countPathEntry() {
  local path_entry="$1"
  local old_ifs="$IFS"
  local part=""
  local count=0

  IFS=:
  for part in $PATH; do
    if [ "$part" = "$path_entry" ]; then
      count=$((count + 1))
    fi
  done
  IFS="$old_ifs"

  printf "%s\n" "$count"
}

assertPathContains() {
  local path_entry="$1"
  local message="$2"

  if ! pathContainsEntry "$path_entry"; then
    die "$message"
  fi
}

assertPathMissing() {
  local path_entry="$1"
  local message="$2"

  if pathContainsEntry "$path_entry"; then
    die "$message"
  fi
}

echo "Checking idempotent managed block appends..."
tmp_lines="$(mktemp)"
printf '%s\n' '}' > "$tmp_lines"
addManagedLinesToFiles "Example Block" "$tmp_lines" -- \
  "" \
  "# Example Block" \
  "example() {" \
  "}"
addManagedLinesToFiles "Example Block" "$tmp_lines" -- \
  "" \
  "# Example Block" \
  "example() {" \
  "}"
assertEquals "1" "$(grep -Fxc "# Example Block (Added by MacSetup)" "$tmp_lines")" "managed block marker should be appended once"
assertEquals "1" "$(grep -Fxc "example() {" "$tmp_lines")" "managed block content should be appended once"
assertEquals "2" "$(grep -Fxc "}" "$tmp_lines")" "managed block should preserve structural lines even when already present"
rm -f "$tmp_lines"

echo "Checking idempotent asdf plugin installation..."
asdf_plugin_adds=0
ASDF_PLUGIN_LIST="nodejs"
asdf() {
  case "$1:$2" in
    plugin:list)
      printf '%s\n' "$ASDF_PLUGIN_LIST"
      ;;
    plugin:add)
      asdf_plugin_adds=$((asdf_plugin_adds + 1))
      ASDF_PLUGIN_LIST="${ASDF_PLUGIN_LIST}
$3"
      ;;
    *)
      return 2
      ;;
  esac
}
installAsdfPlugin nodejs
assertEquals "0" "$asdf_plugin_adds" "existing asdf plugin should not be added again"
installAsdfPlugin python
assertEquals "1" "$asdf_plugin_adds" "missing asdf plugin should be added once"
unset -f asdf
unset ASDF_PLUGIN_LIST

echo "Checking PATH entry detection..."
PATH="/opt/macsetup/bin:/usr/bin:/bin:/Applications/Test App/bin"
assertPathContains "/opt/macsetup/bin" "expected first PATH entry to be detected"
assertPathContains "/usr/bin" "expected middle PATH entry to be detected"
assertPathContains "/Applications/Test App/bin" "expected PATH entry with spaces to be detected"
assertPathMissing "/opt/macsetup" "partial PATH entry should not match"
assertPathMissing "/bin-extra" "suffix-like PATH entry should not match"
assertPathMissing "" "empty PATH entry should not be treated as present"

old_ifs="$IFS"
pathContainsEntry "/usr/bin"
assertEquals "$old_ifs" "$IFS" "pathContainsEntry should restore IFS"

echo "Checking idempotent runtime PATH prepends..."
PATH="/usr/bin:/bin"
prependPathEntry "/opt/macsetup/bin"
prependPathEntry "/opt/macsetup/bin"
assertEquals "/opt/macsetup/bin:/usr/bin:/bin" "$PATH" "prependPathEntry should add a missing entry once"
assertPathCount "/opt/macsetup/bin" 1 "prepended entry should appear exactly once"

PATH="/usr/bin:/opt/macsetup/bin:/bin"
prependPathEntry "/opt/macsetup/bin"
assertEquals "/usr/bin:/opt/macsetup/bin:/bin" "$PATH" "prependPathEntry should not duplicate an existing middle entry"
assertPathCount "/opt/macsetup/bin" 1 "existing middle entry should remain single"

PATH=""
prependPathEntry "/opt/empty-path/bin"
assertEquals "/opt/empty-path/bin" "$PATH" "prependPathEntry should handle an empty PATH"

PATH="/usr/bin:/bin"
prependPathEntry ""
assertEquals "/usr/bin:/bin" "$PATH" "prependPathEntry should ignore an empty input"

PATH="/usr/bin:/bin"
prependPathEntries "/opt/first/bin" "/opt/second bin" "/opt/third/bin"
assertEquals "/opt/first/bin:/opt/second bin:/opt/third/bin:/usr/bin:/bin" "$PATH" "prependPathEntries should preserve caller order"
prependPathEntries "/opt/first/bin" "/opt/second bin" "/opt/third/bin"
assertEquals "/opt/first/bin:/opt/second bin:/opt/third/bin:/usr/bin:/bin" "$PATH" "prependPathEntries should be idempotent"
assertPathCount "/opt/second bin" 1 "multi-prepended path with spaces should appear once"

PATH="/usr/bin:/bin"
prependPathEntries
assertEquals "/usr/bin:/bin" "$PATH" "prependPathEntries with no args should leave PATH unchanged"

echo "Checking idempotent runtime PATH appends..."
PATH="/usr/bin:/bin"
appendPathEntry "/Applications/Test App/bin"
appendPathEntry "/Applications/Test App/bin"
assertEquals "/usr/bin:/bin:/Applications/Test App/bin" "$PATH" "appendPathEntry should add a missing entry once"
assertPathCount "/Applications/Test App/bin" 1 "appended entry should appear exactly once"

PATH="/Applications/Test App/bin:/usr/bin:/bin"
appendPathEntry "/Applications/Test App/bin"
assertEquals "/Applications/Test App/bin:/usr/bin:/bin" "$PATH" "appendPathEntry should not duplicate an existing first entry"

PATH=""
appendPathEntry "/opt/empty-path/bin"
assertEquals "/opt/empty-path/bin" "$PATH" "appendPathEntry should handle an empty PATH"

PATH="/usr/bin:/bin"
appendPathEntry ""
assertEquals "/usr/bin:/bin" "$PATH" "appendPathEntry should ignore an empty input"

echo "Checking generated shell PATH guards..."
tmp_shell="$(mktemp)"
cleanup() {
  rm -f "$tmp_shell"
}
trap cleanup EXIT

{
  pathPrependShellLine '$HOME/.asdf/bin'
  pathPrependShellLine '$HOME/.asdf/shims'
  pathAppendShellLine '/Applications/Test App/bin'
} > "$tmp_shell"

PATH="/usr/bin:/bin"
# shellcheck source=/dev/null
source "$tmp_shell"
# shellcheck source=/dev/null
source "$tmp_shell"

assertEquals "$HOME/.asdf/shims:$HOME/.asdf/bin:/usr/bin:/bin:/Applications/Test App/bin" "$PATH" "generated shell guards should preserve order and append position"
assertPathCount "$HOME/.asdf/bin" 1 "generated prepend guard should add asdf bin once"
assertPathCount "$HOME/.asdf/shims" 1 "generated prepend guard should add asdf shims once"
assertPathCount "/Applications/Test App/bin" 1 "generated append guard should add VSCode-like path once"

echo "Checking generated shell guards use exact PATH matches..."
{
  pathPrependShellLine '/opt/tool/bin'
  pathAppendShellLine '/Applications/Tool.app/bin'
} > "$tmp_shell"

PATH="/opt/tool/bin-extra:/usr/bin:/Applications/Tool.app/bin-extra"
# shellcheck source=/dev/null
source "$tmp_shell"

assertPathCount "/opt/tool/bin" 1 "prepend shell guard should not mistake a prefix match for an existing entry"
assertPathCount "/opt/tool/bin-extra" 1 "prepend shell guard should preserve neighboring prefix-like entry"
assertPathCount "/Applications/Tool.app/bin" 1 "append shell guard should not mistake a prefix match for an existing entry"
assertPathCount "/Applications/Tool.app/bin-extra" 1 "append shell guard should preserve neighboring prefix-like entry"

echo "Checking generated shell guards are safe across multiple startup files..."
zprofile="$(mktemp)"
zshrc="$(mktemp)"
trap 'rm -f "$tmp_shell" "$zprofile" "$zshrc"' EXIT
{
  pathPrependShellLine '$HOME/.asdf/bin'
  pathPrependShellLine '$HOME/.asdf/shims'
} > "$zprofile"
{
  pathPrependShellLine '$HOME/.asdf/bin'
  pathPrependShellLine '$HOME/.asdf/shims'
} > "$zshrc"

PATH="/usr/bin:/bin"
# shellcheck source=/dev/null
source "$zprofile"
# shellcheck source=/dev/null
source "$zshrc"

assertPathCount "$HOME/.asdf/bin" 1 "sourcing zprofile and zshrc should not duplicate asdf bin"
assertPathCount "$HOME/.asdf/shims" 1 "sourcing zprofile and zshrc should not duplicate asdf shims"
