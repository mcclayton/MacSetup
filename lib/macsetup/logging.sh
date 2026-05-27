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
  local old_ifs="${IFS-}"
  local had_ifs=0

  if [ "${IFS+x}" = "x" ]; then
    had_ifs=1
  fi
  IFS='%'
  msg="$YELLOW ⚠ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  if [ "$had_ifs" -eq 1 ]; then
    IFS="$old_ifs"
  else
    unset IFS
  fi
}

info() {
  local msg=""
  local old_ifs="${IFS-}"
  local had_ifs=0

  if [ "${IFS+x}" = "x" ]; then
    had_ifs=1
  fi
  IFS='%'
  msg="$GRAY ⓘ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  if [ "$had_ifs" -eq 1 ]; then
    IFS="$old_ifs"
  else
    unset IFS
  fi
}

success() {
  local msg=""
  local old_ifs="${IFS-}"
  local had_ifs=0

  if [ "${IFS+x}" = "x" ]; then
    had_ifs=1
  fi
  IFS='%'
  msg="$GREEN ✔ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  if [ "$had_ifs" -eq 1 ]; then
    IFS="$old_ifs"
  else
    unset IFS
  fi
}

fail() {
  local msg=""
  local old_ifs="${IFS-}"
  local had_ifs=0

  if [ "${IFS+x}" = "x" ]; then
    had_ifs=1
  fi
  IFS='%'
  msg="$RED ✘ $1 $RESET_COLOR"
  echo -e "$msg"
  echo

  logEntry "$msg"
  FAILURES_ARRAY+=("$msg")
  if [ "$had_ifs" -eq 1 ]; then
    IFS="$old_ifs"
  else
    unset IFS
  fi
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
