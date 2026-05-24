#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
tmp_bin="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home" "$tmp_bin"
}
trap cleanup EXIT

cat > "$tmp_bin/bat" <<'BAT'
#!/bin/sh

case "$1" in
  --config-dir)
    printf '%s\n' "$HOME/.config/bat"
    ;;
  cache)
    if [ "$2" = "--build" ]; then
      mkdir -p "$HOME/.config/bat"
      touch "$HOME/.config/bat/cache-built"
      exit 0
    fi
    exit 2
    ;;
  *)
    exit 2
    ;;
esac
BAT
chmod +x "$tmp_bin/bat"

HOME="$tmp_home" PATH="$tmp_bin:$PATH" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh
  source ./lib/macsetup/appConfigUtil.sh

  configureBat

  test "${#FAILURES_ARRAY[@]}" -eq 0
  test -f "$HOME/.config/bat/themes/Catppuccin Macchiato.tmTheme"
  test -f "$HOME/.config/bat/cache-built"
'
