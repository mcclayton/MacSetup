#!/bin/bash

# Install Homebrew packages
function runSection {
  runPromptedSection "HOMEBREW PACKAGES" installHomebrewPackages
}

installHomebrewPackages() {
  # Can only install brew packages if brew is installed
  if cmdExists brew; then
    local packages=(
      "openssl|openssl|openssl|configureOpenSSL|"
      "icu4c|icu4c|icuinfo|configureICU4C|"
      "fzf|fzf|fzf||"
      "gcc|gcc|gcc||"
      "lolcat|lolcat|lolcat||"
      "wget|wget|wget||"
      "curl|curl|curl||"
      "tree|tree|tree||"
      "gpg|gpg|gpg||"
      "ack|ack|ack||"
      "viu|viu|viu||"
      "yarn|yarn|yarn||"
      "delta (Better 'diff' Command)|git-delta|delta||"
      "ytop (Better 'top' Command)|ytop|ytop||cjbassi/ytop"
      "htop (Alternative 'top' Command)|htop|htop||"
      "bat (Better 'cat' Command)|bat|bat|configureBat|"
      "procs (Better 'ps' Command)|procs|procs||"
      "lsd (Better 'ls' Command)|lsd|lsd||"
      "Ripgrep|ripgrep|rg||"
      "jnv (Interactive jq JSON Viewer)|jnv|jnv||"
      "code-minimap (Text-based minimaps)|code-minimap|code-minimap||"
    )

    installHomebrewPackagesFromList "${packages[@]}"
  else
    fail "Failed to install brew packages. Homebrew is not installed."
  fi
}
