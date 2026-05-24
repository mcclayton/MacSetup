#!/bin/bash

# Install Python via ASDF
function runSection {
  runPromptedSection "INSTALL PYTHON" installPython
}

installPython() {
  installAsdfToolFromToolVersions "python" "Python" "python"
}
