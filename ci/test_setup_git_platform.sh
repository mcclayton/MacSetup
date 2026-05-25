#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"

if [ -z "${TERM:-}" ] || [ "$TERM" = "dumb" ]; then
  export TERM="xterm"
fi

tmp_root="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

writeFakeCommands() {
  local fake_bin="$1"
  local uname_value="$2"

  mkdir -p "$fake_bin"

  cat > "$fake_bin/uname" <<UNAME
#!/bin/sh
if [ "\${1:-}" = "-s" ]; then
  printf '%s\n' "$uname_value"
else
  printf '%s\n' "$uname_value"
fi
UNAME

  cat > "$fake_bin/git" <<'GIT'
#!/bin/sh
exit 0
GIT

  cat > "$fake_bin/ssh-keygen" <<'SSH_KEYGEN'
#!/bin/sh

key_path=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -f)
      shift
      key_path="$1"
      ;;
  esac
  shift
done

if [ -z "$key_path" ]; then
  exit 2
fi

mkdir -p "$(dirname "$key_path")"
touch "$key_path" "$key_path.pub"
SSH_KEYGEN

  cat > "$fake_bin/ssh-agent" <<'SSH_AGENT'
#!/bin/sh
printf '%s\n' 'SSH_AUTH_SOCK=/tmp/macsetup-test-agent.sock; export SSH_AUTH_SOCK;'
printf '%s\n' 'SSH_AGENT_PID=12345; export SSH_AGENT_PID;'
printf '%s\n' 'echo Agent pid 12345;'
SSH_AGENT

  chmod +x "$fake_bin/uname" "$fake_bin/git" "$fake_bin/ssh-keygen" "$fake_bin/ssh-agent"
}

runGitSetupWithPlatform() {
  local uname_value="$1"
  local home_dir="$tmp_root/home-$uname_value"
  local fake_bin="$tmp_root/bin-$uname_value"
  local output_file="$tmp_root/output-$uname_value"

  mkdir -p "$home_dir"
  writeFakeCommands "$fake_bin" "$uname_value"

  {
    printf 'y\n'
    printf 'Test User\n'
    printf 'test@example.com\n'
    printf 'y\n'
    printf '\n'
    printf '\n'
  } | HOME="$home_dir" PATH="$fake_bin:$PATH" MACSETUP_UI=plain TERM="$TERM" bash -c '
    source ./lib/macsetup/constants.sh
    source ./lib/macsetup/helperFunctions.sh
    source ./sections/setup_git.sh
    runSection
  ' > "$output_file"

  printf '%s\n' "$home_dir"
}

echo "Checking Git SSH config on Linux-compatible platforms..."
linux_home="$(runGitSetupWithPlatform Linux)"
linux_ssh_config="$linux_home/.ssh/config"
test -f "$linux_ssh_config"
grep -q "AddKeysToAgent yes" "$linux_ssh_config"
grep -q "IdentityFile $linux_home/.ssh/git_key_ecdsa" "$linux_ssh_config"
! grep -q "UseKeychain yes" "$linux_ssh_config"

echo "Checking Git SSH config on macOS..."
darwin_home="$(runGitSetupWithPlatform Darwin)"
darwin_ssh_config="$darwin_home/.ssh/config"
test -f "$darwin_ssh_config"
grep -q "AddKeysToAgent yes" "$darwin_ssh_config"
grep -q "UseKeychain yes" "$darwin_ssh_config"
grep -q "IdentityFile $darwin_home/.ssh/git_key_ecdsa" "$darwin_ssh_config"
