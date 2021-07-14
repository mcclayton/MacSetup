#!/bin/bash

sandbox() {
  echo "Setting up dockerized sandbox environment..."
  docker build -t macsetup .
  echo "Built docker image for sandbox environment."
  echo "Starting sandbox environment..."
  docker container run --rm -it -h sandbox macsetup /bin/bash -c "./install.sh"
}

function machine() {
  echo "Using current machine environment..."
  ./install.sh
}

### Main ###


echo "ⓘ Sandbox Environment: Installation/Setup changes are made in a dockerized sandbox environment and will not effect the current actual machine."
echo "ⓘ Current Machine: Installation/Setup changes made in this environment will modify and effect the current actual machine."
echo ""

PS3='   => Choose Execution Environment: '
options=("Sandbox (Docker)" "Current Machine" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Sandbox (Docker)")
            sandbox
            break
            ;;
        "Current Machine")
            machine
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
