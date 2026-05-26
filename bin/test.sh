#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

usage() {
  cat <<'USAGE'
Usage: ./test.sh [checks|docker-old|start-sandbox|docker|all]

Modes:
  checks         Run shell syntax, helper, and isolated installer checks.
  docker-old     Run the old Vim Docker sandbox smoke check.
  start-sandbox  Run start.sh through the modern Docker sandbox path.
  docker         Run all Docker-backed smoke checks.
  all            Run checks and Docker-backed smoke checks.

Default mode: checks
USAGE
}

noPrompts() {
  for _ in {1..32}; do
    printf 'n\n'
  done
}

runChecks() {
  echo "Checking shell syntax..."
  find start.sh install.sh clean.sh diff.sh test.sh bin sections lib config assets ci -name '*.sh' -type f -print0 \
    | xargs -0 bash -n

  echo "Checking start.sh quit path..."
  printf '3\n' | ./start.sh

  echo "Checking UI prompt behavior..."
  bash ./ci/test_ui.sh

  echo "Checking PATH helper behavior..."
  bash ./ci/test_path_helpers.sh

  echo "Checking terminal compatibility behavior..."
  bash ./ci/test_terminal_compat.sh

  echo "Checking platform-specific Git config behavior..."
  bash ./ci/test_setup_git_platform.sh

  echo "Checking asdf tool version pins..."
  bash ./ci/test_tool_versions.sh

  echo "Checking config drift diff coverage..."
  bash ./ci/test_diff_configs.sh

  echo "Checking Docker label contract..."
  bash ./ci/test_docker_labels.sh

  echo "Checking install.sh skipped-section path with isolated HOME..."
  local tmp_home
  tmp_home="$(mktemp -d)"
  if ! noPrompts | env HOME="$tmp_home" TERM="${TERM:-xterm}" ./install.sh; then
    rm -rf "$tmp_home"
    return 1
  fi
  rm -rf "$tmp_home"

  echo "Checking focused package configuration behavior..."
  ./ci/test_configure_bat.sh
  ./ci/test_configure_ghostty.sh
}

runDockerOldProfile() {
  bash ./ci/docker_install_smoke.sh vim-old ubuntu:18.04
}

runStartSandbox() {
  {
    printf '1\n'
    printf '2\n'
    noPrompts
  } | ./start.sh
}

mode="${1:-checks}"

case "$mode" in
  checks)
    runChecks
    ;;
  docker-old)
    runDockerOldProfile
    ;;
  start-sandbox)
    runStartSandbox
    ;;
  docker)
    runDockerOldProfile
    runStartSandbox
    ;;
  all)
    runChecks
    runDockerOldProfile
    runStartSandbox
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
