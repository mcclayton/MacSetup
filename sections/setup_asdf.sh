#!/bin/bash

# Set up asdf
function runSection {
  runPromptedSection "ASDF Version Manager" setupAsdf
}

setupAsdf() {
  local currDir="$(scriptDirectory)"
  local asdfDir="$HOME/.asdf"
  local asdfVersion="${ASDF_VERSION:-v0.15.0}"

  if [ -d "$asdfDir/.git" ]; then
    info "asdf repository already exists at $asdfDir"
    if git -C "$asdfDir" rev-parse -q --verify "$asdfVersion^{commit}" >/dev/null 2>&1; then
      info "asdf release $asdfVersion is already available locally"
    else
      runCommand "Fetch asdf release tags" git -C "$asdfDir" fetch --tags --force || return 1
    fi
  else
    if [ -e "$asdfDir" ]; then
      fail "Cannot install asdf because $asdfDir exists but is not a git repository"
      return 1
    fi

    runCommand "Clone asdf version manager $asdfVersion" git clone --branch "$asdfVersion" https://github.com/asdf-vm/asdf.git "$asdfDir" || return 1
  fi

  # MacSetup configures the legacy shell-based asdf loader. asdf v0.16+ changed
  # its install layout, so keep the git install pinned to the matching release.
  runCommand "Checkout asdf release $asdfVersion" git -C "$asdfDir" checkout "$asdfVersion" || return 1

  if [ ! -f "$asdfDir/asdf.sh" ]; then
    fail "Failed to find asdf shell loader at $asdfDir/asdf.sh"
    return 1
  fi

  # shellcheck source=/dev/null
  source "$asdfDir/asdf.sh"
  assertPackageInstallation asdf "asdf"
  cd "$currDir"

  info "Configuring asdf version manager in shell startup files"
  addLineToFiles "" ~/.bash_profile ~/.bashrc ~/.zprofile ~/.zshrc
  addLineToFiles "# asdf version manager" ~/.bash_profile ~/.bashrc ~/.zprofile ~/.zshrc
  addLineToFiles '. $HOME/.asdf/asdf.sh' ~/.bash_profile ~/.bashrc ~/.zprofile ~/.zshrc
  addLineToFiles '. $HOME/.asdf/completions/asdf.bash' ~/.bash_profile ~/.bashrc
  success 'Added asdf configuration to shell startup files'

  info "Backing up ~/.tool-versions"
  backupFile ~/.tool-versions tool-versions

  runCommand "Copy asdf tool versions" cp "$MACSETUP_CONFIG_DIR"/asdf/tool-versions ~/.tool-versions || return 1
  assertFileExists ~/.tool-versions "~/.tool-versions set" "Failed to set ~/.tool-versions"

  assertPackageInstallation asdf "asdf"
}
