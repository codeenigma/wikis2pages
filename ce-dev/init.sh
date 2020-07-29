#!/bin/sh
# Tiny script to setup a new repo.

set -e
IFS='\n'

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)
WIKIS_CONFIG_DIR="$OWN_DIR/ce-dev/ansible/wikis"
WORK_DIR=$(mktemp -d)
CONFIG_FILE=".wikis2pages.yml"
CONFIG_REPO="$1"
CONFIG_BRANCH='master'

if [ -z "$1" ]; then
  echo 'You must pass a git repository as argument.'
  exit 1
fi

if [ -n "$2" ]; then
  CONFIG_BRANCH="$2"
fi

if [ ! -d "$WIKIS_CONFIG_DIR" ]; then
  mkdir "$WIKIS_CONFIG_DIR"
fi

cd "$WORK_DIR"

git clone "$CONFIG_REPO" --branch "$CONFIG_BRANCH" --single-branch --depth 1

REPO_NAME="$(ls | head -1)"

if [ ! -f "$WORK_DIR/$REPO_NAME/$CONFIG_FILE" ]; then
  echo "Could not find a .wikis2pages.yml file in $CONFIG_REPO".
  exit 1
fi

cp "$WORK_DIR/$REPO_NAME/$CONFIG_FILE" "$WIKIS_CONFIG_DIR/$REPO_NAME-$CONFIG_BRANCH.yml"

cd "$OWN_DIR"

ce-dev init
ce-dev start
ce-dev provision