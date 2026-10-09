#!/bin/bash

function runSection {
  promptNewSection "SKILLS"
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Skipping skills setup..."
    return 0
  fi

  chooseOption "Make skills available to:" "Both" "Claude" "Codex" "Skip"
  case "$MACSETUP_UI_CHOICE" in
    Both) setupSkills both ;;
    Claude) setupSkills claude ;;
    Codex) setupSkills codex ;;
    *) info "Skipping skills setup..." ;;
  esac
}
