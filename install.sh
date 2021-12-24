#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

# Bring in constants
source "$(scriptDirectory)/installation/constants.sh"
# Bring in the helper functions
source "$(scriptDirectory)/installation/helperFunctions.sh"
# Bring in the application configuration util
source "$(scriptDirectory)/installation/appConfigUtil.sh"

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
    "setup_screensavers"
    "setup_dot_files"
    "setup_vim"
    "setup_homebrew"
    "install_homebrew_packages"
    "install_applications"
    "setup_asdf"
    "install_ruby"
    "install_node"
    "install_postgres"
    "install_zsh"
    "setup_zsh"
    "change_default_shell"
  )

  for sectionPath in "${sections[@]}"; do
    # Source the section file
    source "$(scriptDirectory)/sections/$sectionPath.sh"
    # Run the section's installation/configuration/setup
    runSection
  done

  finish
}


##############
# Start Main #
##############

# Trap interrupts and call finish
trap finish INT

main
