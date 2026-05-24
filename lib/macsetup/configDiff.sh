#!/bin/bash

################################
# Config Diff Helper Functions #
################################

macsetupDiffFiles() {
  local expected_file="$1"
  local actual_file="$2"
  local diff_status=0

  if cmdExists delta; then
    if command diff -u "$expected_file" "$actual_file" | delta; then
      diff_status="${PIPESTATUS[0]}"
    else
      diff_status="${PIPESTATUS[0]}"
    fi
  elif cmdExists git; then
    if git --no-pager diff --no-index -- "$expected_file" "$actual_file"; then
      diff_status=0
    else
      diff_status="$?"
    fi
  else
    if command diff -u "$expected_file" "$actual_file"; then
      diff_status=0
    else
      diff_status="$?"
    fi
  fi

  return "$diff_status"
}

macsetupFindDotFileChanges() {
  local drift_found=0
  local dotFileName=""
  local local_file=""
  local setup_file=""
  local diff_status=0

  for dotFileName in "${MACSETUP_MANAGED_TOP_LEVEL_DOTFILES[@]}"; do
    local_file="$HOME/.$dotFileName"
    setup_file="$MACSETUP_CONFIG_DIR/dotfiles/mac/$dotFileName.sh"

    if [ ! -f "$setup_file" ]; then
      warn "Managed dotfile source is missing: $setup_file"
      drift_found=1
      continue
    fi

    if [ ! -f "$local_file" ]; then
      warn "Dotfile .$dotFileName is not present on current machine."
      drift_found=1
      continue
    fi

    if macsetupDiffFiles "$setup_file" "$local_file"; then
      diff_status=0
    else
      diff_status="$?"
    fi
    if [ "$diff_status" -ne 0 ]; then
      drift_found=1
    fi
  done

  return "$drift_found"
}
