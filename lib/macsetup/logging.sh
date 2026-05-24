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

# Render a command as a copyable shell-like string for failure logs.
# Accepts command argv exactly as it will be executed.
formatCommandForLog() {
  local formatted=""
  local quoted_arg=""
  local arg=""

  for arg in "$@"; do
    quoted_arg="$(printf '%q' "$arg")"
    if [ -z "$formatted" ]; then
      formatted="$quoted_arg"
    else
      formatted="$formatted $quoted_arg"
    fi
  done

  printf '%s' "$formatted"
}

# Append a captured stdout or stderr file to the install log.
# This intentionally writes only to LOG_ARRAY so terminal output stays concise.
logCommandOutputFile() {
  local label="$1"
  local file_path="$2"
  local line=""

  if [ -s "$file_path" ]; then
    logEntry "    $label:"
    while IFS= read -r line || [ -n "$line" ]; do
      logEntry "      $line"
    done < "$file_path"
  else
    logEntry "    $label: <empty>"
  fi
}

# Add detailed captured command failure diagnostics to LOG_ARRAY.
# Call this after the user-facing fail/warn line has already been recorded.
logCommandFailureDetails() {
  local command_text="$1"
  local status="$2"
  local stdout_file="$3"
  local stderr_file="$4"

  logEntry "    Command: $command_text"
  logEntry "    Exit code: $status"
  logCommandOutputFile "stdout" "$stdout_file"
  logCommandOutputFile "stderr" "$stderr_file"
}

# Add failure diagnostics for commands that must keep direct terminal access.
# Use for commands that may prompt or manage their own terminal UI.
logInteractiveCommandFailureDetails() {
  local command_text="$1"
  local status="$2"

  logEntry "    Command: $command_text"
  logEntry "    Exit code: $status"
  logEntry "    stdout/stderr: not captured because command ran interactively"
}

# Run a command while capturing stdout into the caller-provided file and stderr
# into a temporary file. On failure, terminal output is a short failure message
# and the generated log receives command, exit code, stdout, and stderr.
#
# Usage:
#   output_file="$(mktemp)"
#   runCommandCapture "Find tool path" "$output_file" asdf where postgres
runCommandCapture() {
  local description="$1"
  local stdout_file="$2"
  shift 2
  local stderr_file=""
  local command_text=""
  local status=0

  if [ "$#" -eq 0 ]; then
    fail "$description failed: no command provided"
    return 1
  fi

  stderr_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stderr.XXXXXX")" || {
    fail "$description failed: could not create stderr capture file"
    return 1
  }
  command_text="$(formatCommandForLog "$@")"

  "$@" > "$stdout_file" 2> "$stderr_file"
  status="$?"

  if [ "$status" -ne 0 ]; then
    fail "$description failed"
    logCommandFailureDetails "$command_text" "$status" "$stdout_file" "$stderr_file"
    rm -f "$stderr_file"
    return "$status"
  fi

  rm -f "$stderr_file"
  return 0
}

# Run a command and assign its captured stdout to a named variable.
# Use this instead of command substitution when the command can fail and the log
# should include command, exit code, stdout, and stderr details.
#
# Usage:
#   runCommandOutputVariable brewPrefix "Find Homebrew prefix" brew --prefix
runCommandOutputVariable() {
  local variable_name="$1"
  local description="$2"
  shift 2
  local stdout_file=""
  local output_value=""
  local status=0

  stdout_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stdout.XXXXXX")" || {
    fail "$description failed: could not create stdout capture file"
    return 1
  }

  if runCommandCapture "$description" "$stdout_file" "$@"; then
    output_value="$(< "$stdout_file")"
    printf -v "$variable_name" '%s' "$output_value"
  else
    status="$?"
    rm -f "$stdout_file"
    return "$status"
  fi

  rm -f "$stdout_file"
  return 0
}

# Run an exploratory command and assign stdout to a named variable when it
# succeeds. Use this for probing candidate paths where failure should not print
# to the terminal or count toward FAILURES_ARRAY because a later probe may
# succeed. Failed probes still write command, exit code, stdout, and stderr to
# the generated log.
#
# Usage:
#   runProbeCommandOutputVariable brewShellenv "Probe brew shellenv" "$brewPath" shellenv
runProbeCommandOutputVariable() {
  local variable_name="$1"
  local description="$2"
  shift 2
  local stdout_file=""
  local stderr_file=""
  local command_text=""
  local output_value=""
  local status=0

  if [ "$#" -eq 0 ]; then
    warn "$description skipped: no command provided"
    return 1
  fi

  stdout_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stdout.XXXXXX")" || {
    warn "$description skipped: could not create stdout capture file"
    return 1
  }
  stderr_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stderr.XXXXXX")" || {
    rm -f "$stdout_file"
    warn "$description skipped: could not create stderr capture file"
    return 1
  }
  command_text="$(formatCommandForLog "$@")"

  "$@" > "$stdout_file" 2> "$stderr_file"
  status="$?"

  if [ "$status" -eq 0 ]; then
    output_value="$(< "$stdout_file")"
    printf -v "$variable_name" '%s' "$output_value"
  else
    logEntry "    Probe failed: $description"
    logCommandFailureDetails "$command_text" "$status" "$stdout_file" "$stderr_file"
  fi

  rm -f "$stdout_file" "$stderr_file"
  return "$status"
}

# Run a non-interactive command whose output is only useful on failure.
# Use for installs, copies, Git operations, and other shell-outs where normal
# stdout/stderr would add noise to the installer UI.
#
# Usage:
#   runCommand "Copy vimrc" cp "$source" "$HOME/.vimrc"
runCommand() {
  local description="$1"
  shift
  local stdout_file=""
  local status=0

  stdout_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stdout.XXXXXX")" || {
    fail "$description failed: could not create stdout capture file"
    return 1
  }

  runCommandCapture "$description" "$stdout_file" "$@"
  status="$?"
  rm -f "$stdout_file"

  return "$status"
}

# Run a command directly attached to the terminal.
# Use for commands that may prompt, need stdin, or own their terminal output.
# Failure logs include command and exit code, but stdout/stderr are not captured.
#
# Usage:
#   runInteractiveCommand "Run Homebrew installer" /bin/bash "$installer"
runInteractiveCommand() {
  local description="$1"
  shift
  local command_text=""
  local status=0

  if [ "$#" -eq 0 ]; then
    fail "$description failed: no command provided"
    return 1
  fi

  command_text="$(formatCommandForLog "$@")"
  "$@"
  status="$?"

  if [ "$status" -ne 0 ]; then
    fail "$description failed"
    logInteractiveCommandFailureDetails "$command_text" "$status"
    return "$status"
  fi

  return 0
}

# Run a best-effort command that should not count as an install failure.
# Use for cleanup or advisory checks. Failures are warnings, and captured
# stdout/stderr still go to the generated log for debugging.
#
# Usage:
#   runOptionalCommand "Run brew doctor" brew doctor || true
runOptionalCommand() {
  local description="$1"
  shift
  local stdout_file=""
  local stderr_file=""
  local command_text=""
  local status=0

  if [ "$#" -eq 0 ]; then
    warn "$description skipped: no command provided"
    return 1
  fi

  stdout_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stdout.XXXXXX")" || {
    warn "$description skipped: could not create stdout capture file"
    return 1
  }
  stderr_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-command-stderr.XXXXXX")" || {
    rm -f "$stdout_file"
    warn "$description skipped: could not create stderr capture file"
    return 1
  }
  command_text="$(formatCommandForLog "$@")"

  "$@" > "$stdout_file" 2> "$stderr_file"
  status="$?"

  if [ "$status" -ne 0 ]; then
    warn "$description failed"
    logCommandFailureDetails "$command_text" "$status" "$stdout_file" "$stderr_file"
  fi

  rm -f "$stdout_file" "$stderr_file"
  return "$status"
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
