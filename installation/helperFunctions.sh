#!/bin/bash

####################
# Helper Functions #
####################

# Returns whether or not a command exists
function cmdExists {
  if hash $1 2>/dev/null; then
    true
  else
    false
  fi
}

function finish {
  # Finish
  echo
  IFS='' read -r -d '' FINISH_MESSAGE <<'EOF'
 ___ ___ _  _ ___ ___ _  _ ___ ___
| __|_ _| \| |_ _/ __| || | __|   \
| _| | || .` || |\__ \ __ | _|| |) |
|_| |___|_|\_|___|___/_||_|___|___/
EOF

  printInRainbow "$FINISH_MESSAGE"
  echo
  echo -e "$GRAY INSTALLATION COMPLETE.$RESET_COLOR"
  echo -e "$GRAY (May need to open new shell to experience all changes.)$RESET_COLOR"
  echo

  if [ ${#FAILURES_ARRAY[@]} -eq 0 ]; then
      success "No failures occurred during install"

      promptYesNo "Would you like to open a new shell to experience the new changes?"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        exec bash
      fi
  else
      warn "The following failures occurred during install"
      # Print failures
      printFailures
  fi
  echo
  exit 0
}

function printIntro {
  # Intro
  echo
  IFS='' read -r -d '' INSTALL_MESSAGE <<'EOF'
 _____           _        _ _
|_   _|         | |      | | |
  | |  _ __  ___| |_ __ _| | |
  | | | '_ \/ __| __/ _` | | |
 _| |_| | | \__ \ || (_| | | |
|_____|_| |_|___/\__\__,_|_|_|
EOF
  printInRainbow "$INSTALL_MESSAGE"
  echo
}

promptYesNo() {
    echo "   => $1 "
    read -p "      [Y/n] " -r
    echo
}

prompt() {
    IFS= read -r -p "   => $1 "
    unset IFS
    echo
}

warn() {
    echo "$YELLOW ⚠ $1 $RESET_COLOR"
    echo
}

info() {
    echo -e "$GRAY ⓘ $1 $RESET_COLOR"
    echo
}

success() {
    echo -e "$GREEN ✔ $1 $RESET_COLOR"
    echo
}

# Keep track of all the errors for printing at the end of install
FAILURES_ARRAY=()
fail() {
    # Preserve white space by changing the Internal Field Separator
    IFS='%'
    NEW_ERROR="$RED ✘ $1 $RESET_COLOR"
    # Add error to array
    FAILURES_ARRAY+=($NEW_ERROR)
    # Print error
    echo -e "$NEW_ERROR"
    # Reset the Internal Field Separator
    unset IFS
    echo
}

# Print out all failures line by line in the FAILURES_ARRAY
printFailures() {
    for failure in "${FAILURES_ARRAY[@]}"; do
        echo -e "    -> $failure"
    done
}

# Gets the repo name given a full git url
repoName() {
    # Get the name of the repo in format 'myRepo.git'
    basename=$(basename $1)
    # Echo out repo name in format 'myRepo'
    echo "${basename%.*}"
}

# Backs up file $1 (if it exists) to location $2
backupFile() {
    if [ ! -f $1 ]; then
        warn "$1 Does not exist, skipping backup..."
    else
        cp $1 $2
        success "Backed up $1 to $2"
    fi
}

# Backs up directory $1 (if it exists) to location $2
backupDir() {
    if [ ! -d $1 ]; then
        warn "$1 Does not exist, skipping backup..."
    else
        cp -r $1 $2
        success "Backed up $1 to $2"
    fi
}

# Install package $1 via the command $2.
# Configure via command $3 if passed
installPackage() {
    info "Installing Package: $1"
    if cmdExists $1; then
        info "$1 is already installed"
    else
        $2
        # Run Config Command if present
        if [ ! -z "$3" ]; then
            $3
        fi
    fi
}

# Install application named $1 via the cask name $2 only if it does
# not already exist at path /Applications/$1
# Configure via command $3 if passed
caskInstallAppPrompt() {
    promptYesNo "Install application $1?"

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Install Application
        info "Installing Application: $1"
        if brew cask ls --versions $2 > /dev/null; then
            warn "$1 is already installed. Prompting overwrite..."
            promptYesNo "Do you want to $RED OVERWRITE $RESET_COLOR application $1?"
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "/Applications/$1"
                # Run re-install command
                brew cask reinstall $2
                # Run Config Command if present
                if [ ! -z "$3" ]; then
                    $3
                fi
            else
                info "Skipping overwrite..."
            fi
        else
            # Run install command
            brew cask install $2
            # Run Config Command if present
            if [ ! -z "$3" ]; then
                $3
            fi
        fi
        # Assert application is installed correctly
        assertAppInstallation "$1"
    else
        # Skip this installation section
        info "Skipping Installation..."
    fi
}

# Assert $1 directory exists and display $2 success message if it does
# or display $3 error message otherwise
assertDirectoryExists() {
    if [ -d $1 ]; then
        success "$2"
    else
        fail "$3"
    fi
}

# Assert $1 file exists and display $2 success message if it does
# or display $3 error message otherwise
assertFileExists() {
    if [ -f $1 ]; then
        success "$2"
    else
        fail "$3"
    fi
}

isMacOs() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
  esac
  if [ "$machine" = "Mac" ]; then
    true
  else
    false
  fi
}

assertPackageInstallation() {
    # $1 is command to assert existence in order to verify correct installation
    # $2 is name of command
    if cmdExists $1; then
        success "Successfully installed $2"
    else
        fail "Failed to install $2"
    fi
}

assertAppInstallation() {
    # Assert application $1 exists at /Applications/$1
    if [ -d "/Applications/$1" ]; then
        success "Successfully installed $1 and added to Applications"
    else
        fail "Failed to install $1"
    fi
}

promptNewSection() {
    echo
    echo "$ORANGE[=== $1 ===] $RESET_COLOR"
    promptYesNo "Proceed with section?"
}

manualAction() {
    echo -e "[MANUAL ACTION REQUIRED]: $1"
    read -p "   => Press Enter To Continue:"
}

printInRainbow() {
    if cmdExists lolcat; then
        printf "$1" | lolcat
    else
        printf "$1"
    fi
}
