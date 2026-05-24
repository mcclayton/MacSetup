#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
code --list-extensions > "$script_dir/extensions.list"
