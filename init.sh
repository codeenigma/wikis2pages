#!/bin/sh
# Script to initialise a new wiki2pages project.
set -e

# Load OS information.
# shellcheck source=/dev/null
. /etc/os-release

usage(){
  /usr/bin/echo 'init.sh [OPTIONS]'
  /usr/bin/echo 'Initialise a wiki2pages project with the repo and branch provided.'
  /usr/bin/echo ''
  /usr/bin/echo 'Available options:'
  /usr/bin/echo '--repo: target repo containing your .wiki2pages.yml config file and markdown'
  /usr/bin/echo '--branch: branch to use in target repo (default is main)'
  /usr/bin/echo '--no-ce-dev: do not start ce-dev once the config is complete'
  /usr/bin/echo ''
}

# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--repo")
          shift
          CONFIG_REPO="$1"
        ;;
      "--branch")
          shift
          CONFIG_BRANCH="$1"
        ;;
      "--no-ce-dev")
          NO_CE_DEV="true"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Set default variables.
CONFIG_BRANCH="main"
NO_CE_DEV="false"

# Parse options.
parse_options "$@"

if [ -z "$CONFIG_REPO" ]; then
  /usr/bin/echo 'ABORTING! You must pass a git repository as argument.'
  exit 1
fi

OWN_DIR=$(/usr/bin/dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(/usr/bin/git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(/usr/bin/pwd -P)
WIKIS_CONFIG_DIR="$OWN_DIR/ce-dev/ansible/wikis"
WORK_DIR=$(/usr/bin/mktemp -d)
CONFIG_FILE=".wikis2pages.yml"

if [ ! -d "$WIKIS_CONFIG_DIR" ]; then
  /usr/bin/echo "-------------------------------------------------"
  /usr/bin/echo "Creating $WIKIS_CONFIG_DIR"
  mkdir "$WIKIS_CONFIG_DIR"
fi

/usr/bin/echo "-------------------------------------------------"
cd "$WORK_DIR"
/usr/bin/echo "Checking out the $CONFIG_BRANCH branch of the repo at $CONFIG_REPO into $WORK_DIR"
/usr/bin/git clone "$CONFIG_REPO" --branch "$CONFIG_BRANCH" --single-branch --depth 1

REPO_NAME="$(ls | head -1)"
if [ ! -f "$WORK_DIR/$REPO_NAME/$CONFIG_FILE" ]; then
  /usr/bin/echo "ABORTING! Could not find a .wikis2pages.yml file in $CONFIG_REPO".
  exit 1
fi

/usr/bin/echo "-------------------------------------------------"
/usr/bin/echo "Creating $WIKIS_CONFIG_DIR/$REPO_NAME-$CONFIG_BRANCH.yml as a copy of $WORK_DIR/$REPO_NAME/$CONFIG_FILE"
/usr/bin/cp "$WORK_DIR/$REPO_NAME/$CONFIG_FILE" "$WIKIS_CONFIG_DIR/$REPO_NAME-$CONFIG_BRANCH.yml"

cd "$OWN_DIR"

if [ "$NO_CE_DEV" = "false" ]; then
  /usr/bin/echo "-------------------------------------------------"
  /usr/bin/echo "Initialising ce-dev"
  /usr/local/bin/ce-dev init
  /usr/local/bin/ce-dev start
  /usr/local/bin/ce-dev provision
fi
/usr/bin/echo "-------------------------------------------------"
