#!/bin/bash

# Install Ruby via ASDF
function runSection {
  runPromptedSection "INSTALL RUBY" installRuby
}

installRuby() {
  installAsdfToolFromToolVersions "ruby" "Ruby" "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
}
