# Find a process running on a port
findProcessOnPort() {
  PORT=$1
  lsof -n -i4TCP:$PORT | grep LISTEN
}

# Print out 256 color codes / palette for use in terminal, vim, etc.
termColors() {
  for i in {0..255} ; do
    printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
    if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
        printf "\n";
    fi
  done
}

# Returns whether or not a command exists
cmdExists() {
  if hash $1 2>/dev/null; then
    true
  else
    false
  fi
}

# Open up the network tab of a github project. First argument is the Github org. or user
network() {
  REPO_NAME=$(basename `git rev-parse --show-toplevel`)
  echo $REPO_NAME
  /usr/bin/open -a "/Applications/Google Chrome.app" "https://github.com/$1/$REPO_NAME/network"
}

# Get logs for a specified heroku app
hlogs() {
  APP_NAME=$1
  if [ ! -z "$APP_NAME" ]; then
    heroku logs -t --app $APP_NAME
  else
    echo "Error: No heroku app name specified."
  fi
}

# Display text in rainbow if lolcat installed, else regular text
rainbowtext() {
  TEXT=$1 && shift
  if cmdExists lolcat; then
    printf "$TEXT" | lolcat "$@"
  else
    printf "$TEXT"
  fi
}

# Shows the diff changes of each stashed commit. Press [Q] to exit each stash
showStashes() {
	git stash list | awk -F: '{ print "\n\n\n\n"; print $0; print "\n\n"; system("git stash show -p " $1); }'
}

# Force replace a local branch with the remote branch
replaceBranch() {
  BRANCH_NAME=$1
  if [ ! -z "$BRANCH_NAME" ]; then
    echo "-- Deleting local branch $BRANCH_NAME..."
    git branch -D $BRANCH_NAME
    echo "-- Fetching origin branch $BRANCH_NAME..."
    git fetch origin $BRANCH_NAME
    echo "-- Checking out new branch $BRANCH_NAME..."
    git checkout -b $BRANCH_NAME origin/$BRANCH_NAME
  else
    echo "Error: branch name specified."
  fi
}

# Return your terminal session to sanity
sanity() {
  stty sane
  echo "Sanity restored."
}

# Simple service startup aliases
startCassandra() {
  sudo cassandra -f
}
startZookeeper() {
  /usr/local/opt/kafka/bin/zookeeper-server-start.sh /usr/local/etc/kafka/zookeeper.properties
}
startKafka() {
  /usr/local/opt/kafka/bin/kafka-server-start.sh /usr/local/etc/kafka/server.properties
}
stopKafka() {
  /usr/local/opt/kafka/bin/kafka-server-stop.sh /usr/local/etc/kafka/server.properties
}
startRedis() {
  redis-server
}

###################
# Aliases for fzf #
###################

# Fuzzy File Preview/Open
fo() (
  if cmdExists bat; then
    IFS=$'\n' out=("$(fzf-tmux --preview 'bat --style=numbers --color=always {} | head -500' --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  else
    IFS=$'\n' out=("$(fzf-tmux --preview 'cat {} | head -500' --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  fi
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
)

# Fuzzy Change Directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

##################################################
# Override Unix tools with enhanced replacements #
##################################################

# Use ytop, else, htop, else top
top() {
  if cmdExists ytop; then
    ytop
  elif cmdExists htop; then
    htop
  else
    # Invoke original command
    command top
  fi
}

# Use delta, git diff, else diff for diffing
function diff {
  if cmdExists delta; then
    delta "$@"
  elif cmdExists git; then
    git diff "$@"
  else
    # Invoke original command
    command diff "$@"
  fi
}

# Override cat tool with bat's as it looks better
function cat {
  if cmdExists bat; then
    bat --style=plain "$@"
  else
    # Invoke original command
    command cat "$@"
  fi
}

# Override ps tool with procs' as it looks better
function ps {
  if cmdExists procs; then
    procs "$@"
  else
    # Invoke original command
    command ps "$@"
  fi
}

# Override ls tool with lsd as it looks better
function ls {
  if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
    command ls "$@"
  elif cmdExists lsd; then
    lsd "$@"
  else
    # Invoke original command
    command ls "$@"
  fi
}
