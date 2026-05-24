#!/bin/bash

# Install Postgres via ASDF
function runSection {
  runPromptedSection "INSTALL POSTGRES" installPostgres
}

installPostgres() {
  local postgres_path_file=""
  local POSTGRES_PATH=""

  installAsdfToolFromToolVersions "postgres" "Postgres" "postgres" || return 1

  if cmdExists postgres; then
    postgres_path_file="$(mktemp "${TMPDIR:-/tmp}/macsetup-postgres-path.XXXXXX")" || {
      fail "Failed to create temporary file for Postgres install path"
      return 1
    }

    if ! runCommandCapture "Find Postgres asdf install path" "$postgres_path_file" asdf where postgres; then
      rm -f "$postgres_path_file"
      return 1
    fi

    IFS= read -r POSTGRES_PATH < "$postgres_path_file"
    rm -f "$postgres_path_file"

    info "Adding postgres utility alias to ~/.utility_aliases"
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
}
