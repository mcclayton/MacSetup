#!/bin/bash

#######################
# Assertion Functions #
#######################

assertDirectoryExists() {
  if [ -d "$1" ]; then
    success "$2"
  else
    fail "$3"
  fi
}

assertFileExists() {
  if [ -f "$1" ]; then
    success "$2"
  else
    fail "$3"
  fi
}

assertPackageInstallation() {
  if cmdExists "$1"; then
    success "Successfully installed $2"
  else
    fail "Failed to install $2"
  fi
}

assertAppInstallation() {
  if [ -d "/Applications/$1" ]; then
    success "Successfully installed $1 and added to Applications"
  else
    fail "Failed to install $1"
  fi
}
