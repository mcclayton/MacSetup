#!/bin/bash

# Prints path to directory containing this script
function scriptDirectory {
  local self_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo "$self_dir"
}

# Bring in constants
source "$(scriptDirectory)/lib/macsetup/constants.sh"
# Bring in the helper functions
source "$(scriptDirectory)/lib/macsetup/helperFunctions.sh"
# Bring in the application configuration util
source "$(scriptDirectory)/lib/macsetup/appConfigUtil.sh"

# Main Function
function main {
  # Create root setup folder
  mkdir -p $ROOT_MAC_SETUP_FOLDER

  # Print out the intro message
  printIntro

  # Check to make sure script is not initially run as root.
  ensureNotRoot

  # Execute each section's installation/configuration/setup
  sectionRegistryLoad
  local sectionIndex=1
  local sectionTotal="${#MACSETUP_SECTION_PATHS[@]}"

  for sectionPath in "${MACSETUP_SECTION_PATHS[@]}"; do
    MACSETUP_SECTION_INDEX="$sectionIndex"
    MACSETUP_SECTION_TOTAL="$sectionTotal"

    # Source the section file
    source "$(scriptDirectory)/sections/$sectionPath.sh"
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
