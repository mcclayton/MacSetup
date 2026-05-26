#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_home"
}
trap cleanup EXIT

for dot_file in bashrc bash_profile profile zshrc zprofile utility_aliases config_vars splash_screens tmux.conf; do
  cp "$repo_root/config/dotfiles/mac/$dot_file.sh" "$tmp_home/.$dot_file"
done

mkdir -p "$tmp_home/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$tmp_home/Library/Preferences"

cp "$repo_root/config/asdf/tool-versions" "$tmp_home/.tool-versions"
cp "$repo_root/config/terminal/ghostty/config" "$tmp_home/Library/Application Support/com.mitchellh.ghostty/config"
printf '%s\n' '<plist version="1.0"><dict><key>Different</key><true/></dict></plist>' > "$tmp_home/Library/Preferences/com.googlecode.iterm2.plist"

output_file="$tmp_home/diff-output"
HOME="$tmp_home" ./diff.sh > "$output_file" 2>&1 || true

grep -q "Diffing iTerm2 preferences" "$output_file"
grep -q "com.googlecode.iterm2.plist" "$output_file"
