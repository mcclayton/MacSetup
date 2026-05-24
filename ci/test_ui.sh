#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

echo "Checking plain UI option selection..."
printf '2\n' | MACSETUP_UI=plain TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  chooseOption "Choose Test Option:" "First" "Second" "Third"

  [ "$REPLY" = "2" ]
  [ "$MACSETUP_UI_INDEX" = "1" ]
  [ "$MACSETUP_UI_CHOICE" = "Second" ]
'

echo "Checking plain UI yes/no selection..."
printf 'n\n' | MACSETUP_UI=plain TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  promptYesNo "Proceed?"

  [ "$REPLY" = "n" ]
'

echo "Checking plain UI default selection..."
printf '\n' | MACSETUP_UI=plain TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  promptYesNo "Proceed?"

  [ "$REPLY" = "y" ]
'

echo "Checking plain UI EOF fallback..."
MACSETUP_UI=plain TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  promptYesNo "Proceed?"

  [ "$REPLY" = "n" ]
' </dev/null

echo "Checking arrow-key decoding on macOS Bash..."
printf '\033[B' | TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  uiReadKey

  [ "$MACSETUP_UI_KEY" = $'\''\033[B'\'' ]
'

echo "Checking interactive UI arrow selection..."
printf '\033[B\n' | TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  output_file="$(mktemp)"
  uiChooseInteractive "Choose Test Option:" 0 "First" "Second" >"$output_file"
  rm -f "$output_file"

  [ "$REPLY" = "2" ]
  [ "$MACSETUP_UI_INDEX" = "1" ]
  [ "$MACSETUP_UI_CHOICE" = "Second" ]
'

echo "Checking section menu footer rendering..."
MACSETUP_UI_ASCII=true TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  MACSETUP_UI_TITLE="SETTING UP SCREENSAVERS"
  MACSETUP_UI_FOOTER="Section 5/19"
  output="$(uiRenderChoiceMenu "Proceed with section?" 0 "Yes" "No")"

  printf "%s" "$output" | grep -q "SETTING UP SCREENSAVERS"
  printf "%s" "$output" | grep -q "Section 5/19"
  ! printf "%s" "$output" | grep -q "=>"
'

echo "Checking forced rounded UI rendering..."
MACSETUP_UI_FORCE_ROUNDED=true LANG= LC_ALL= LC_CTYPE= TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  uiSetBoxChars

  [ "$MACSETUP_UI_BOX_STYLE" = "rounded" ]
'

echo "Checking terminal-based Unicode detection..."
TERM_PROGRAM=Apple_Terminal LANG= LC_ALL= LC_CTYPE= TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  uiSetBoxChars

  [ "$MACSETUP_UI_BOX_STYLE" = "rounded" ]
'

echo "Checking ASCII UI override..."
MACSETUP_UI_FORCE_ROUNDED=true MACSETUP_UI_ASCII=true LANG=en_US.UTF-8 TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  uiSetBoxChars

  [ "$MACSETUP_UI_BOX_STYLE" = "ascii" ]
'

echo "Checking start.sh has no Bash select prompts..."
if rg -n "^[[:space:]]*select[[:space:]]" start.sh sections lib; then
  echo "Found Bash select prompt usage"
  exit 1
fi
