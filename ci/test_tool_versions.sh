#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

tool_versions="config/asdf/tool-versions"

test -f "$tool_versions"

for tool in ruby nodejs python postgres; do
  grep -q "^$tool " "$tool_versions"
done

grep -q "^nodejs 18.19.0$" "$tool_versions"
grep -q "^ruby 3.0.1$" "$tool_versions"
grep -q "^postgres 10.14$" "$tool_versions"
grep -q "^python 3.8.10$" "$tool_versions"

! grep -q "^bazel " "$tool_versions"
! grep -q "^java " "$tool_versions"
! grep -q "^golang " "$tool_versions"
