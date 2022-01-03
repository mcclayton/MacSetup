#!/bin/bash

# Install Python via ASDF
function runSection {
  promptNewSection "INSTALL PYTHON"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if cmdExists asdf; then
      assertFileExists ~/.tool-versions "Found ~/.tool-versions file" "~/.tool-versions not found, cannot install Python via \`asdf\`."

      info "Adding Python Plugin..."
      asdf plugin-add python

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing Python from ~/.tool-versions: "$'\n'"---TOOLS---"$'\n'"$(cat ~/.tool-versions)"$'\n'"-----------"
        asdf install python
        assertPackageInstallation python "python"
      fi
    else
      fail "Failed to install python. \`asdf\` is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
