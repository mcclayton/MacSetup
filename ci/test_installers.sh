#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
tmp_bin="$(mktemp -d)"
tmp_state="$(mktemp -d)"
brew_log="$tmp_state/brew.log"
cleanup() {
  rm -rf "$tmp_home" "$tmp_bin" "$tmp_state"
}
trap cleanup EXIT

cat > "$tmp_bin/brew" <<'BREW'
#!/bin/bash

set -euo pipefail

case "$1" in
  list|ls)
    if [ "${2:-}" = "--formula" ] && [ "${3:-}" = "--versions" ]; then
      test -f "$BREW_STATE/formula-$4"
      exit "$?"
    fi
    exit 2
    ;;
  tap)
    echo "tap $2" >> "$BREW_LOG"
    ;;
  install)
    echo "install $2" >> "$BREW_LOG"
    touch "$BREW_STATE/formula-$2"
    cat > "$TMP_BIN/probe-command" <<'COMMAND'
#!/bin/sh
exit 0
COMMAND
    chmod +x "$TMP_BIN/probe-command"
    ;;
  *)
    exit 2
    ;;
esac
BREW
chmod +x "$tmp_bin/brew"

echo "Checking Homebrew package helper install and rerun behavior..."
HOME="$tmp_home" \
PATH="$tmp_bin:$PATH" \
TERM="${TERM:-xterm}" \
BREW_LOG="$brew_log" \
BREW_STATE="$tmp_state" \
TMP_BIN="$tmp_bin" \
bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh
  set -euo pipefail

  configureProbe() {
    echo "configure probe" >> "$BREW_LOG"
  }

  installHomebrewPackagesFromList "Probe Package|probe-formula|probe-command|configureProbe|example/tap"
  installHomebrewPackagesFromList "Probe Package|probe-formula|probe-command|configureProbe|example/tap"

  test "$(grep -cFx "tap example/tap" "$BREW_LOG")" -eq 1
  test "$(grep -cFx "install probe-formula" "$BREW_LOG")" -eq 1
  test "$(grep -cFx "configure probe" "$BREW_LOG")" -eq 2
  test "${#FAILURES_ARRAY[@]}" -eq 0
'
