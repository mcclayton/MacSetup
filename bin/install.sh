#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
  echo "$self_dir"
}

REPO_ROOT="$(scriptDirectory)"
cd "$REPO_ROOT"

# Bring in constants
source "$REPO_ROOT/lib/macsetup/constants.sh"
# Bring in the helper functions
source "$REPO_ROOT/lib/macsetup/helperFunctions.sh"
# Bring in the application configuration util
source "$REPO_ROOT/lib/macsetup/appConfigUtil.sh"

# Main Function
function main {
  # Create root setup folder
  mkdir -p $ROOT_MAC_SETUP_FOLDER

  # Print out the intro message
  printIntro

  # Check to make sure script is not initially run as root.
  ensureNotRoot

  # Execute each section's installation/configuration/setup
  sections=(
    "install_xcode_and_git"
    "setup_git"
    "setup_fonts"
    "setup_wallpaper"
    "setup_screensavers"
    "setup_dot_files"
    "setup_splash_screen"
    "setup_vim"
    "setup_homebrew"
    "install_homebrew_packages"
    "install_applications"
    "setup_asdf"
    "install_ruby"
    "install_node"
    "install_python"
    "install_postgres"
    "install_zsh"
    "setup_zsh"
    "change_default_shell"
  )

  local sectionIndex=1
  local sectionTotal="${#sections[@]}"

  for sectionPath in "${sections[@]}"; do
    MACSETUP_SECTION_INDEX="$sectionIndex"
    MACSETUP_SECTION_TOTAL="$sectionTotal"

    # Source the section file
    source "$REPO_ROOT/sections/$sectionPath.sh"
    # Run the section's installation/configuration/setup
    runSection

    sectionIndex=$((sectionIndex + 1))
  done

  unset MACSETUP_SECTION_INDEX
  unset MACSETUP_SECTION_TOTAL

  finish
}


##############
# Start Main #
##############

# Trap interrupts and call finish
trap finish INT

main
