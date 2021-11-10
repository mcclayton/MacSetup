#!/bin/bash

# Install Postgres via ASDF
function runSection {
  promptNewSection "INSTALL POSTGRES"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if cmdExists asdf; then
      assertFileExists ~/.tool-versions "Found ~/.tool-versions file" "~/.tool-versions not found, cannot install Postgres via \`asdf\`."

      info "Adding Postgres Plugin..."
      asdf plugin-add postgres

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing Postgres from ~/.tool-versions: "$'\n'"---TOOLS---"$'\n'"$(cat ~/.tool-versions)"$'\n'"-----------"
        asdf install postgres
        assertPackageInstallation postgres "postgres"
      fi
    else
      fail "Failed to install postgres. \`asdf\` is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
