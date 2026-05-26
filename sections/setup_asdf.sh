#!/bin/bash

# Set up asdf
function runSection {
  promptNewSection "ASDF Version Manager"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    setupAsdf
  else
    # Skip this installation section
    info "Skipping..."
  fi
}

function setupAsdf {
  local asdfVersion="${ASDF_VERSION:-v0.19.0}"
  local asdfDataDir="${ASDF_DATA_DIR:-$HOME/.asdf}"
  local asdfBinDir="$asdfDataDir/bin"
  local asdfBinary="$asdfBinDir/asdf"

  export ASDF_DATA_DIR="$asdfDataDir"

  if ! mkdir -p "$asdfBinDir" "$asdfDataDir/shims"; then
    fail "Failed to create asdf directories under $asdfDataDir"
    return 1
  fi

  if ! installAsdfBinary "$asdfVersion" "$asdfBinary"; then
    return 1
  fi

  prependPathEntries "$asdfDataDir/shims" "$asdfBinDir"
  hash -r 2>/dev/null || true
  assertPackageInstallation asdf "asdf"
  if ! cmdExists asdf; then
    return 1
  fi
  if ! assertAsdfVersion "$asdfVersion"; then
    return 1
  fi

  if ! configureAsdfShell "$asdfDataDir"; then
    return 1
  fi

  info "Backing up ~/.tool-versions"
  backupFile ~/.tool-versions tool-versions

  if ! cp "$MACSETUP_CONFIG_DIR"/asdf/tool-versions ~/.tool-versions; then
    fail "Failed to copy asdf tool versions"
    return 1
  fi
  assertFileExists ~/.tool-versions "~/.tool-versions set" "Failed to set ~/.tool-versions"

  assertPackageInstallation asdf "asdf"
}

function installAsdfBinary {
  local asdfVersion="$1"
  local asdfBinary="$2"
  local installedVersion=""
  local platform=""
  local arch=""
  local archiveName=""
  local archiveUrl=""
  local tmpDir=""
  local archivePath=""

  if [ -x "$asdfBinary" ]; then
    installedVersion="$("$asdfBinary" --version 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^v?[0-9]+\.[0-9]+\.[0-9]+$/) { print $i; exit } }')"
    if [ "$installedVersion" = "$asdfVersion" ] || [ "$installedVersion" = "${asdfVersion#v}" ]; then
      info "asdf $asdfVersion is already installed at $asdfBinary"
      return 0
    fi
  fi

  platform="$(asdfReleasePlatform)" || return 1
  arch="$(asdfReleaseArch)" || return 1
  archiveName="asdf-${asdfVersion}-${platform}-${arch}.tar.gz"
  archiveUrl="https://github.com/asdf-vm/asdf/releases/download/${asdfVersion}/${archiveName}"
  tmpDir="$(mktemp -d 2>/dev/null || mktemp -d -t macsetup-asdf)"
  if [ -z "$tmpDir" ]; then
    fail "Failed to create temporary directory for asdf download"
    return 1
  fi
  archivePath="$tmpDir/$archiveName"

  info "Downloading asdf $asdfVersion for $platform/$arch"
  if cmdExists curl; then
    if ! curl -fsSL "$archiveUrl" -o "$archivePath"; then
      fail "Failed to download asdf from $archiveUrl"
      rm -rf "$tmpDir"
      return 1
    fi
  elif cmdExists wget; then
    if ! wget -qO "$archivePath" "$archiveUrl"; then
      fail "Failed to download asdf from $archiveUrl"
      rm -rf "$tmpDir"
      return 1
    fi
  else
    fail "Failed to download asdf: curl or wget is required"
    rm -rf "$tmpDir"
    return 1
  fi

  if ! tar -xzf "$archivePath" -C "$tmpDir"; then
    fail "Failed to extract $archiveName"
    rm -rf "$tmpDir"
    return 1
  fi

  if [ ! -f "$tmpDir/asdf" ]; then
    fail "Failed to find asdf binary in $archiveName"
    rm -rf "$tmpDir"
    return 1
  fi

  if ! cp "$tmpDir/asdf" "$asdfBinary"; then
    fail "Failed to install asdf binary to $asdfBinary"
    rm -rf "$tmpDir"
    return 1
  fi

  if ! chmod +x "$asdfBinary"; then
    fail "Failed to make asdf binary executable at $asdfBinary"
    rm -rf "$tmpDir"
    return 1
  fi
  rm -rf "$tmpDir"
  success "Installed asdf $asdfVersion to $asdfBinary"
}

function assertAsdfVersion {
  local expectedVersion="$1"
  local activeVersion=""

  activeVersion="$(asdf --version 2>/dev/null)"
  if echo "$activeVersion" | grep -Fq "${expectedVersion#v}"; then
    success "Using asdf $expectedVersion"
    return 0
  fi

  fail "Expected asdf $expectedVersion, but found: $activeVersion"
  return 1
}

function asdfReleasePlatform {
  case "$(uname -s)" in
    Darwin)
      echo "darwin"
      ;;
    Linux)
      echo "linux"
      ;;
    *)
      fail "Unsupported asdf platform: $(uname -s)"
      return 1
      ;;
  esac
}

function asdfReleaseArch {
  case "$(uname -m)" in
    arm64 | aarch64)
      echo "arm64"
      ;;
    x86_64 | amd64)
      echo "amd64"
      ;;
    i386 | i686)
      echo "386"
      ;;
    *)
      fail "Unsupported asdf architecture: $(uname -m)"
      return 1
      ;;
  esac
}

function configureAsdfShell {
  local asdfDataDir="$1"
  local files=(~/.bash_profile ~/.bashrc ~/.zprofile ~/.zshrc)

  info "Configuring asdf version manager in shell startup files"
  removeLegacyAsdfShellConfig "${files[@]}" || return 1
  addAsdfLineToFiles "" "${files[@]}"
  addAsdfLineToFiles "# asdf version manager" "${files[@]}"
  addAsdfLineToFiles "export ASDF_DATA_DIR=\"$asdfDataDir\"" "${files[@]}"
  addAsdfLineToFiles "$(pathPrependShellLine '$ASDF_DATA_DIR/bin')" "${files[@]}"
  addAsdfLineToFiles "$(pathPrependShellLine '$ASDF_DATA_DIR/shims')" "${files[@]}"
  success "Added asdf configuration to shell startup files"
}

function addAsdfLineToFiles {
  local text="$1"
  local files=("${@:2}")
  local file=""
  local line="$text"

  if [[ $text =~ ^\# ]]; then
    line="$text (Added by MacSetup)"
  fi

  for file in "${files[@]}"; do
    touch "$file"
    if ! grep -Fqx "$line" "$file"; then
      echo "$line" >> "$file"
    fi
  done
}

function removeLegacyAsdfShellConfig {
  local files=("$@")
  local file=""
  local tmpFile=""

  for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
      continue
    fi

    if grep -Fqx \
      -e '. $HOME/.asdf/asdf.sh' \
      -e '. $HOME/.asdf/completions/asdf.bash' \
      -e 'export PATH="$ASDF_DATA_DIR/bin:$ASDF_DATA_DIR/shims:$PATH"' \
      "$file"; then
      backupFile "$file" "$(basename "$file")"
      tmpFile="$(mktemp)"
      grep -Fvx \
        -e '. $HOME/.asdf/asdf.sh' \
        -e '. $HOME/.asdf/completions/asdf.bash' \
        -e 'export PATH="$ASDF_DATA_DIR/bin:$ASDF_DATA_DIR/shims:$PATH"' \
        "$file" > "$tmpFile" || true
      if ! cp "$tmpFile" "$file"; then
        fail "Failed to remove legacy asdf shell config from $file"
        rm -f "$tmpFile"
        return 1
      fi
      rm -f "$tmpFile"
      info "Removed legacy asdf shell config from $file"
    fi
  done
}
