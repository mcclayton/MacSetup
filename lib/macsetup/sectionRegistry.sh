#!/bin/bash

##############################
# Installer Section Registry #
##############################

MACSETUP_SECTION_REGISTRY=(
  "install_xcode_and_git|XCODE COMMAND LINE TOOLS + GIT|mac"
  "setup_git|CONFIGURE GIT|all"
  "setup_fonts|SETTING UP FONTS|mac"
  "setup_wallpaper|SETTING DESKTOP WALLPAPER|mac"
  "setup_screensavers|SETTING UP SCREENSAVERS|mac"
  "setup_dot_files|SETTING UP TOP-LEVEL DOT FILES|all"
  "setup_splash_screen|SETTING UP SPLASH SCREEN|all"
  "setup_vim|SETTING UP VIM|all"
  "setup_homebrew|HOMEBREW PACKAGE MANAGER|all"
  "install_homebrew_packages|HOMEBREW PACKAGES|all"
  "install_applications|APPLICATIONS|mac"
  "setup_asdf|ASDF Version Manager|all"
  "install_ruby|INSTALL RUBY|all"
  "install_node|INSTALL NODE|all"
  "install_python|INSTALL PYTHON|all"
  "install_postgres|INSTALL POSTGRES|all"
  "install_zsh|INSTALL ZSH|all"
  "setup_zsh|SET UP ZSH|all"
  "change_default_shell|CHANGE DEFAULT SHELL|all"
)

MACSETUP_SECTION_PATHS=()
MACSETUP_SECTION_TITLES=()
MACSETUP_SECTION_PLATFORMS=()

sectionRegistryLoad() {
  local entry=""
  local path=""
  local title=""
  local platform=""

  MACSETUP_SECTION_PATHS=()
  MACSETUP_SECTION_TITLES=()
  MACSETUP_SECTION_PLATFORMS=()

  for entry in "${MACSETUP_SECTION_REGISTRY[@]}"; do
    IFS='|' read -r path title platform <<< "$entry"
    MACSETUP_SECTION_PATHS+=("$path")
    MACSETUP_SECTION_TITLES+=("$title")
    MACSETUP_SECTION_PLATFORMS+=("$platform")
  done
}

sectionPlatformReason() {
  case "$1" in
    "mac")
      echo "Mac only"
      ;;
    "all"|"")
      echo ""
      ;;
    *)
      echo "$1"
      ;;
  esac
}

sectionPathForIndex() {
  echo "${MACSETUP_SECTION_PATHS[$1]}"
}

sectionTitleForIndex() {
  echo "${MACSETUP_SECTION_TITLES[$1]}"
}

sectionPlatformForIndex() {
  echo "${MACSETUP_SECTION_PLATFORMS[$1]}"
}
