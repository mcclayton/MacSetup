#!/bin/bash

# Install Node via ASDF
function runSection {
  promptNewSection "INSTALL NODE"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if cmdExists asdf; then
      assertFileExists ~/.tool-versions "Found ~/.tool-versions file" "~/.tool-versions not found, cannot install Node via \`asdf\`."

      info "Adding Node Plugin..."
      asdf plugin-add nodejs

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing Node from ~/.tool-versions: "$'\n'"---TOOLS---"$'\n'"$(cat ~/.tool-versions)"$'\n'"-----------"
        asdf install nodejs
        assertPackageInstallation node "node"
      fi
    else
      fail "Failed to install node. \`asdf\` is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
