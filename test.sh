#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
  bash ./ci/checks.sh
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
