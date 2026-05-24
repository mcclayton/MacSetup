#!/bin/bash

#####################
# Logging Functions #
#####################

LOG_ARRAY=()
FAILURES_ARRAY=()

logEntry() {
  local msg="$1"
  LOG_ARRAY+=("$msg")
}

warn() {
  local msg=""

  IFS='%'
  msg="$YELLOW ⚠ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  unset IFS
}

info() {
  local msg=""

  IFS='%'
  msg="$GRAY ⓘ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  unset IFS
}

success() {
  local msg=""

  IFS='%'
  msg="$GREEN ✔ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  unset IFS
}

fail() {
  local msg=""

  IFS='%'
  msg="$RED ✘ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  FAILURES_ARRAY+=("$msg")
  unset IFS
}

generateLog() {
  touch "$LOG_PATH"
  echo "" > "$LOG_PATH"

  echo "::: MAC SETUP LOG :::" >> "$LOG_PATH"
  echo "---------------------" >> "$LOG_PATH"
  echo >> "$LOG_PATH"
  echo >> "$LOG_PATH"

  for entry in "${LOG_ARRAY[@]}"; do
    echo -e "$entry" >> "$LOG_PATH"
  done
}

printFailures() {
  local failure=""

  for failure in "${FAILURES_ARRAY[@]}"; do
    echo -e "    -> $failure"
  done
}
