#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

source ./lib/macsetup/constants.sh

test "$MACSETUP_DOCKER_LABEL_KEY" = "macsetup"
test "$MACSETUP_DOCKER_LABEL_VALUE" = "true"
test "$MACSETUP_DOCKER_LABEL" = "macsetup=true"
test "$MACSETUP_DOCKER_LABEL_FILTER" = "label=macsetup=true"

grep -q "LABEL macsetup=true" Dockerfile
grep -q -- '--label "$MACSETUP_DOCKER_LABEL"' bin/start.sh
grep -q -- '--label "$MACSETUP_DOCKER_LABEL"' ci/docker_install_smoke.sh
grep -q -- '--filter "$MACSETUP_DOCKER_LABEL_FILTER"' bin/clean.sh
