#!/bin/bash

# Set up asdf
function runSection {
  promptNewSection "ASDF Version Manager"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    local currDir="$(scriptDirectory)";
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    cd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"

    source $HOME/.asdf/asdf.sh
    assertPackageInstallation asdf "asdf"
    cd "$currDir"

    info "Configuring asdf version manager in .bash_profile and .zprofile"
    addLineToFiles "" ~/.bash_profile ~/.zprofile
    addLineToFiles "# asdf version manager" ~/.bash_profile ~/.zprofile
    addLineToFiles '. $HOME/.asdf/asdf.sh' ~/.bash_profile ~/.zprofile
    addLineToFiles '. $HOME/.asdf/completions/asdf.bash' ~/.bash_profile # This line does not apply to .zprofile
    success 'Added asdf configuration to ~/.bash_profile and ~/.zprofile'

    source ~/.bash_profile
    source ~/.zprofile

    info "Backing up ~/.tool-versions"
    backupFile ~/.tool-versions tool-versions

    cp "$(scriptDirectory)"/.tool-versions ~/.tool-versions
    assertFileExists ~/.tool-versions "~/.tool-versions set" "Failed to set ~/.tool-versions"

    assertPackageInstallation asdf "asdf"
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
