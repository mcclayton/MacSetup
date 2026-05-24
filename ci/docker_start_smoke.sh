#!/bin/bash

set -euo pipefail

profile="${1:-vim-modern}"

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

case "$profile" in
  vim-old)
    profile_choice=1
    ;;
  vim-modern)
    profile_choice=2
    ;;
  *)
    echo "Usage: ci/docker_start_smoke.sh [vim-old|vim-modern]" >&2
    exit 2
    ;;
esac

no_prompts() {
  for _ in {1..32}; do
    printf 'n\n'
  done
}

{
  printf '1\n'
  printf '%s\n' "$profile_choice"
  no_prompts
} | ./start.sh
