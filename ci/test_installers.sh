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
    if [ "$2" = "broken-formula" ]; then
      echo "brew stdout-line"
      echo "brew stderr-line" >&2
      exit 55
    fi
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

echo "Checking Homebrew package failures are detailed in the log only..."
failure_output="$tmp_state/brew-failure.out"
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

  mkdir -p "$ROOT_MAC_SETUP_FOLDER"

  if installHomebrewPackage "Broken Package" "broken-formula" ""; then
    exit 1
  fi

  test "${#FAILURES_ARRAY[@]}" -eq 1
  generateLog
' > "$failure_output"

grep -q "Install Homebrew package Broken Package failed" "$failure_output"
! grep -q "brew stdout-line" "$failure_output"
! grep -q "brew stderr-line" "$failure_output"

grep -qFx "    Exit code: 55" "$tmp_home/.mac_setup/log"
grep -qFx "      brew stdout-line" "$tmp_home/.mac_setup/log"
grep -qFx "      brew stderr-line" "$tmp_home/.mac_setup/log"

cat > "$tmp_bin/asdf" <<'ASDF'
#!/bin/bash

set -euo pipefail

case "$1" in
  plugin)
    if [ "$2" = "list" ]; then
      find "$BREW_STATE" -name "asdf-plugin-*" -type f -exec basename {} \; | sed "s/^asdf-plugin-//"
      exit 0
    fi
    exit 2
    ;;
  plugin-add)
    echo "plugin-add $2" >> "$BREW_LOG"
    touch "$BREW_STATE/asdf-plugin-$2"
    ;;
  install)
    echo "install $2" >> "$BREW_LOG"
    case "$2" in
      nodejs)
        cat > "$TMP_BIN/node" <<'NODE'
#!/bin/sh
exit 0
NODE
        chmod +x "$TMP_BIN/node"
        ;;
    esac
    ;;
  *)
    exit 2
    ;;
esac
ASDF
chmod +x "$tmp_bin/asdf"

echo "Checking asdf package helper install and rerun behavior..."
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

  : > "$BREW_LOG"
  printf "%s\n" "nodejs 22.0.0" > "$HOME/.tool-versions"

  installAsdfToolFromToolVersions "nodejs" "Node" "node"
  installAsdfToolFromToolVersions "nodejs" "Node" "node"

  test "$(grep -cFx "plugin-add nodejs" "$BREW_LOG")" -eq 1
  test "$(grep -cFx "install nodejs" "$BREW_LOG")" -eq 2
  test "${#FAILURES_ARRAY[@]}" -eq 0
'
