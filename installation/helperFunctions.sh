#!/bin/bash

####################
# Helper Functions #
####################

function ensureNotRoot {
  if [ "$EUID" -eq 0 ]
    then
    warn "Please do not run entire script as root."
    info "Exiting..."
    exit
  fi
}

# Returns whether or not a command exists
function cmdExists {
  if hash $1 2>/dev/null; then
    true
  else
    false
  fi
}

function currShell {
  if cmdExists finger; then
    local curr_shell=$(finger $USER | grep 'Shell:*' | cut -f3 -d ":")
    echo "$curr_shell"
  else
    local curr_shell=$(grep ^$(id -un): /etc/passwd | cut -d : -f 7-)
    echo "$curr_shell"
  fi
}

# Keep track of all prompts, success, info, and error logs
LOG_ARRAY=()
logEntry() {
  MSG=$1
  # Add message to logs
  LOG_ARRAY+=("$MSG")
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

  generateLog

  if [ ${#FAILURES_ARRAY[@]} -eq 0 ]; then
    success "No failures occurred during install"
  else
    warn "The following failures occurred during install"
    # Print failures
    printFailures
  fi

  echo
  info "View Summary Log: $LOG_PATH"

  echo
  promptYesNo "Would you like to open a new shell to experience the new changes?"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    exec $(currShell)
  fi
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
  sandboxIntro
  echo
}

sandboxIntro() {
  if [ "$SANDBOX" = true ] ; then
    echo
    echo "✨ Running In [SANDBOX] Mode ✨"
    echo "    | Changes made from script will not persist and"
    echo "    | are made in a dockerized sandbox environment."
    echo "    | Note: Not all steps are available in sandbox."
  fi
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
  # Preserve white space by changing the Internal Field Separator
  IFS='%'
  MSG="$YELLOW ⚠ $1 $RESET_COLOR"
  # Print message
  echo -e $MSG
  echo

  logEntry $MSG
  # Reset the Internal Field Separator
  unset IFS
}

info() {
  # Preserve white space by changing the Internal Field Separator
  IFS='%'
  MSG="$GRAY ⓘ $1 $RESET_COLOR"
  # Print message
  echo -e $MSG
  echo

  logEntry $MSG
  # Reset the Internal Field Separator
  unset IFS
}

success() {
  # Preserve white space by changing the Internal Field Separator
  IFS='%'
  MSG="$GREEN ✔ $1 $RESET_COLOR"
  # Print message
  echo -e $MSG
  echo

  logEntry $MSG
  # Reset the Internal Field Separator
  unset IFS
}

# Keep track of all the errors for printing at the end of install
FAILURES_ARRAY=()
fail() {
  # Preserve white space by changing the Internal Field Separator
  IFS='%'
  MSG="$RED ✘ $1 $RESET_COLOR"
  # Print message
  echo -e $MSG
  echo

  logEntry $MSG
  # Add message to array
  FAILURES_ARRAY+=($MSG)
  # Reset the Internal Field Separator
  unset IFS
}

generateLog() {
  touch $LOG_PATH

  echo "::: MAC SETUP LOG :::" >> $LOG_PATH
  echo "---------------------" >> $LOG_PATH
  echo >> $LOG_PATH
  echo >> $LOG_PATH

  for entry in "${LOG_ARRAY[@]}"; do
    echo -e $entry >> $LOG_PATH
  done
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

# Backs up file $1 (if it exists) to location $BACKUP_DIRECTORY/$2
backupFile() {
  local original_path=$1
  local new_file_name=$2

  mkdir -p $BACKUP_DIRECTORY

  if [ ! -f $original_path ]; then
    warn "$original_path Does not exist, skipping backup..."
  else
    local date_folder="$(date +'%m_%d_%Y')"
    local suffix="__$(date +'%s')"
    local new_file="$BACKUP_DIRECTORY/$date_folder/$new_file_name$suffix"
    # Ensure base directory exists
    if [ ! -d $new_file ]; then
      mkdir -p $new_file
    fi

    cp $1 $new_file
    if [ -a $new_file ]; then
      success "Backed up $1 to $new_file"
    else
      fail "Failed to backup file $1 to $new_file"
    fi
  fi
}

addLineToFiles() {
  local text=$1
  local files_arr=("${@:2}")
  for file in "${files_arr[@]}"; do
    if [[ $text =~ ^\# ]]; then
      # Add to initial comments that this section was added by MacSetup
      echo "$text (Added by MacSetup)" >> $file
    else
      echo $text >> $file
    fi
  done
}

# Backs up directory $1 (if it exists) to location $BACKUP_DIRECTORY/$2
backupDir() {
  local original_path=$1
  local new_directory_name=$2

  mkdir -p $BACKUP_DIRECTORY

  if [ ! -d $original_path ]; then
    warn "$original_path Does not exist, skipping backup..."
  else
    local date_folder="$(date +'%m_%d_%Y')"
    local suffix="__$(date +'%s')"
    local new_dir="$BACKUP_DIRECTORY/$date_folder/$new_directory_name$suffix"
    # Ensure base directory exists
    if [ ! -d $new_dir ]; then
      mkdir -p $new_dir
    fi

    cp -r $1 $new_dir
    if [ -d $new_dir ]; then
      success "Backed up directory $1 to $new_dir"
    else
      fail "Failed to backup directory $1 to $new_dir"
    fi
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
    if brew ls --cask --versions $2 > /dev/null; then
      warn "$1 is already installed. Prompting overwrite..."
      promptYesNo "Do you want to $RED OVERWRITE $RESET_COLOR application $1?"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "/Applications/$1"
        # Run re-install command
        brew reinstall --cask $2
        # Run Config Command if present
        if [ ! -z "$3" ]; then
            $3
        fi
      else
        info "Skipping overwrite..."
      fi
      else
        # Run install command
        brew install --cask $2
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
  TITLE="[=== $1 ===]"
  echo "$ORANGE$TITLE $RESET_COLOR"
  logEntry "$TITLE"

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
