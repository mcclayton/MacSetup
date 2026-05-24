#!/bin/bash

# Install Node via ASDF
function runSection {
  runPromptedSection "INSTALL NODE" installNode
}

installNode() {
  installAsdfToolFromToolVersions "nodejs" "Node" "node"
}
