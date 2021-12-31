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


        if cmdExists $1; then
          info "Adding postgres utility alias to ~/.utility_aliases"
          POSTGRES_PATH=$(asdf where postgres)
          # Preserve white space by changing the Internal Field Separator
          IFS='%'
          addLineToFiles "" ~/.utility_aliases
          addLineToFiles "# Start Postgres" ~/.utility_aliases
          addLineToFiles "startPostgres() {" ~/.utility_aliases
          addLineToFiles "  $POSTGRES_PATH/bin/pg_ctl -D $POSTGRES_PATH/data start" ~/.utility_aliases
          addLineToFiles "}" ~/.utility_aliases
          # Reset the Internal Field Separator
          unset IFS

          if grep -q "# Start Postgres" ~/.utility_aliases; then
            success "Utility alias 'startPostgres' has been set"
          else
            fail "Failed to set utility alias 'startPostgres'"
          fi
        fi
      fi
    else
      fail "Failed to install postgres. \`asdf\` is required to install."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
