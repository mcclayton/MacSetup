#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
tmp_bin="$(mktemp -d)"
stderr_file="$(mktemp)"
cleanup() {
  rm -rf "$tmp_home" "$tmp_bin" "$stderr_file"
}
trap cleanup EXIT

cat > "$tmp_bin/lolcat" <<'LOLCAT'
#!/bin/sh
cat >/dev/null
LOLCAT
chmod +x "$tmp_bin/lolcat"

echo "Checking startup helpers with unknown Ghostty terminfo..."
HOME="$tmp_home" \
PATH="$tmp_bin:$PATH" \
TERM=xterm-ghostty \
COLUMNS= \
bash -c '
  source ./lib/macsetup/constants.sh
  source ./config/dotfiles/mac/utility_aliases.sh
  source ./config/dotfiles/mac/splash_screens.sh

  test "$(splashTerminalColumns)" = "80"
  wolf >/dev/null
  charizard >/dev/null
' 2>"$stderr_file"

if [ -s "$stderr_file" ]; then
  cat "$stderr_file" >&2
  exit 1
fi

if command -v zsh >/dev/null 2>&1; then
  echo "Checking zsh startup with unknown Ghostty terminfo..."
  rm -f "$stderr_file"
  mkdir -p "$tmp_home/.oh-my-zsh"
  touch "$tmp_home/.oh-my-zsh/oh-my-zsh.sh"
  cp ./config/dotfiles/mac/zshrc.sh "$tmp_home/.zshrc"
  cp ./config/dotfiles/mac/bashrc.sh "$tmp_home/.bashrc"
  cp ./config/dotfiles/mac/config_vars.sh "$tmp_home/.config_vars"
  cp ./config/dotfiles/mac/utility_aliases.sh "$tmp_home/.utility_aliases"
  cp ./config/dotfiles/mac/splash_screens.sh "$tmp_home/.splash_screens"
  sed -i.bak 's/local SPLASH_COMMAND=.*/local SPLASH_COMMAND=wolf/' "$tmp_home/.bashrc"

  HOME="$tmp_home" \
  PATH="$tmp_bin:$PATH" \
  TERM=xterm-ghostty \
  zsh -i -c exit >/dev/null 2>"$stderr_file"

  if [ -s "$stderr_file" ]; then
    cat "$stderr_file" >&2
    exit 1
  fi

  echo "Checking zsh splash clear with missing terminfo fallback..."
  rm -f "$stderr_file"
  printf '%s\n' 'DISABLE_NERD_FONT_ICONS=false' > "$tmp_home/.config_vars"

  HOME="$tmp_home" \
  PATH="$tmp_bin:$PATH" \
  TERM=xterm-ghostty \
  zsh -i -c exit >/dev/null 2>"$stderr_file"

  if [ -s "$stderr_file" ]; then
    cat "$stderr_file" >&2
    exit 1
  fi
fi
