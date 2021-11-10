#!/bin/bash

# Install Ruby via ASDF
function runSection {
  promptNewSection "INSTALL RUBY"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if cmdExists asdf; then
      assertFileExists ~/.tool-versions "Found ~/.tool-versions file" "~/.tool-versions not found, cannot install Ruby via \`asdf\`."

      info "Adding Ruby Plugin..."
      asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing Ruby from ~/.tool-versions: "$'\n'"---TOOLS---"$'\n'"$(cat ~/.tool-versions)"$'\n'"-----------"
        asdf install ruby
        assertPackageInstallation ruby "ruby"
      fi
    else
      fail "Failed to install ruby. \`asdf\` is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
