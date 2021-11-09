#!/bin/bash
echo "Pruning docker resources with label: 'macsetup'..."
docker system prune --filter "label=macsetup" --force
