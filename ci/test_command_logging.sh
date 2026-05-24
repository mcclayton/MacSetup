#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tmp_home="$(mktemp -d)"
tmp_output="$(mktemp)"
tmp_stderr="$(mktemp)"
cleanup() {
  rm -rf "$tmp_home"
  rm -f "$tmp_output" "$tmp_stderr"
}
trap cleanup EXIT

echo "Checking command failure details are logged..."
HOME="$tmp_home" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  mkdir -p "$ROOT_MAC_SETUP_FOLDER"

  if runCommand "Run failing probe command" bash -c "printf \"%s\n\" stdout-line; printf \"%s\n\" stderr-line >&2; exit 42"; then
    exit 1
  fi

  test "${#FAILURES_ARRAY[@]}" -eq 1

  generateLog
' > "$tmp_output" 2> "$tmp_stderr"

log_path="$tmp_home/.mac_setup/log"

grep -q "Run failing probe command failed" "$tmp_output"
! grep -q "    Exit code: 42" "$tmp_output"
! grep -q "      stdout-line" "$tmp_output"
! grep -q "      stderr-line" "$tmp_output"
! grep -q "Command: bash -c" "$tmp_output"
test ! -s "$tmp_stderr"

grep -qFx "    Exit code: 42" "$log_path"
grep -qFx "      stdout-line" "$log_path"
grep -qFx "      stderr-line" "$log_path"
grep -q "Command: bash -c" "$log_path"

echo "Checking command output can be captured without losing failure logs..."
HOME="$tmp_home" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  mkdir -p "$ROOT_MAC_SETUP_FOLDER"

  runCommandOutputVariable captured_value "Capture probe command output" bash -c "printf \"%s\" captured"
  test "$captured_value" = "captured"

  if runCommandOutputVariable failed_value "Capture failing probe command output" bash -c "printf \"%s\n\" captured-stdout; printf \"%s\n\" captured-stderr >&2; exit 64"; then
    exit 1
  fi

  generateLog

  grep -qFx "    Exit code: 64" "$LOG_PATH"
  grep -qFx "      captured-stdout" "$LOG_PATH"
  grep -qFx "      captured-stderr" "$LOG_PATH"
' > "$tmp_output" 2> "$tmp_stderr"

grep -q "Capture failing probe command output failed" "$tmp_output"
! grep -q "captured-stdout" "$tmp_output"
! grep -q "captured-stderr" "$tmp_output"
test ! -s "$tmp_stderr"

echo "Checking exploratory probe failures only write to the log..."
HOME="$tmp_home" TERM="${TERM:-xterm}" bash -c '
  source ./lib/macsetup/constants.sh
  source ./lib/macsetup/helperFunctions.sh

  mkdir -p "$ROOT_MAC_SETUP_FOLDER"

  runProbeCommandOutputVariable probe_value "Probe successful command" bash -c "printf \"%s\" probe-value"
  test "$probe_value" = "probe-value"

  if runProbeCommandOutputVariable failed_probe_value "Probe failing command" bash -c "printf \"%s\n\" probe-stdout; printf \"%s\n\" probe-stderr >&2; exit 70"; then
    exit 1
  fi

  test "${#FAILURES_ARRAY[@]}" -eq 0
  generateLog

  grep -qFx "    Probe failed: Probe failing command" "$LOG_PATH"
  grep -qFx "    Exit code: 70" "$LOG_PATH"
  grep -qFx "      probe-stdout" "$LOG_PATH"
  grep -qFx "      probe-stderr" "$LOG_PATH"
' > "$tmp_output" 2> "$tmp_stderr"

! grep -q "Probe failing command" "$tmp_output"
! grep -q "probe-stdout" "$tmp_output"
! grep -q "probe-stderr" "$tmp_output"
test ! -s "$tmp_stderr"
