# Find a process running on a port
findProcessOnPort() {
  PORT=$1
  lsof -n -i4TCP:$PORT | grep LISTEN
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
