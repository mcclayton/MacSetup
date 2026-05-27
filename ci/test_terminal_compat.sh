#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

runWithoutStderr() {
  local stderr_file=""

  stderr_file="$(mktemp)"
  if ! "$@" 2>"$stderr_file"; then
    sed -n '1,120p' "$stderr_file" >&2
    rm -f "$stderr_file"
    return 1
  fi

  if [ -s "$stderr_file" ]; then
    sed -n '1,120p' "$stderr_file" >&2
    rm -f "$stderr_file"
    return 1
  fi

  rm -f "$stderr_file"
}

echo "Checking constants with unknown Ghostty TERM..."
runWithoutStderr env TERM=xterm-ghostty bash -c '
  source ./lib/macsetup/constants.sh
  test -n "$RED"
  test -n "$RESET_COLOR"
'

echo "Checking constants with dumb TERM..."
runWithoutStderr env TERM=dumb bash -c '
  source ./lib/macsetup/constants.sh
  test -z "$RED"
  test -z "$RESET_COLOR"
'

echo "Checking splash screens with unknown Ghostty TERM..."
runWithoutStderr env TERM=xterm-ghostty bash -c '
  source ./config/dotfiles/mac/config_vars.sh
  source ./config/dotfiles/mac/utility_aliases.sh
  source ./config/dotfiles/mac/splash_screens.sh
  wolf >/dev/null
  charizard >/dev/null
'

echo "Checking splash clear fallback with unknown Ghostty TERM..."
runWithoutStderr env TERM=xterm-ghostty bash -c '
  tmp_home="$(mktemp -d)"
  cleanup() {
    rm -rf "$tmp_home"
  }
  trap cleanup EXIT
  cp ./config/dotfiles/mac/config_vars.sh "$tmp_home/.config_vars"
  cp ./config/dotfiles/mac/utility_aliases.sh "$tmp_home/.utility_aliases"
  cp ./config/dotfiles/mac/splash_screens.sh "$tmp_home/.splash_screens"
  HOME="$tmp_home"
  source ./config/dotfiles/mac/bashrc.sh || true
  declare -F clearTerminal >/dev/null
  clearTerminal >/dev/null
'

if command -v zsh >/dev/null 2>&1; then
  echo "Checking zsh startup does not source bash-only bindings..."
  runWithoutStderr env TERM=xterm bash -c '
    tmp_home="$(mktemp -d)"
    cleanup() {
      rm -rf "$tmp_home"
    }
    trap cleanup EXIT
    cp ./config/dotfiles/mac/config_vars.sh "$tmp_home/.config_vars"
    cp ./config/dotfiles/mac/utility_aliases.sh "$tmp_home/.utility_aliases"
    cp ./config/dotfiles/mac/splash_screens.sh "$tmp_home/.splash_screens"
    cp ./config/dotfiles/mac/ps1.sh "$tmp_home/.ps1"
    cp ./config/dotfiles/mac/shell_common.sh "$tmp_home/.shell_common"
    cp ./config/dotfiles/mac/zshrc.sh "$tmp_home/.zshrc"
    mkdir -p "$tmp_home/.oh-my-zsh"
    touch "$tmp_home/.oh-my-zsh/oh-my-zsh.sh"
    HOME="$tmp_home" zsh -f -ic "source \"\$HOME/.zshrc\""
  '
fi
