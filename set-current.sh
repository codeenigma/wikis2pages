#!/bin/sh
# Tiny script to setup a new repo.

set -e
IFS='\n'

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

if [ ! -d "$OWN_DIR/content/ce-dev" ]; then
  git clone https://github.com/codeenigma/ce-dev.git --branch 1.x "$OWN_DIR/content/ce-dev"
fi
if [ ! -d "$OWN_DIR/public/ce-dev" ]; then
  git clone git@github.com:codeenigma/ce-dev-docs.git --branch master "$OWN_DIR/public/ce-dev"
fi
if [ ! -d "$OWN_DIR/content/wikis2pages-demo" ]; then
  git clone https://github.com/codeenigma/wikis2pages-demo.wiki.git --branch master "$OWN_DIR/content/wikis2pages-demo"
fi
if [ ! -d "$OWN_DIR/public/wikis2pages-demo" ]; then
  git clone https://github.com/codeenigma/wikis2pages-demo.git --branch master "$OWN_DIR/public/wikis2pages-demo"
fi

echo "Which project do you want to use?"
echo "1) ce-dev"
echo "2) wikis2pages-demo"

read CURRENT

case $CURRENT in
  "1")
    echo "current: ce-dev" > "$OWN_DIR/ce-dev/ansible/current.yml"
  ;;
  "2")
    echo "current: wikis2pages-demo" > "$OWN_DIR/ce-dev/ansible/current.yml"
  ;;
  *)
    echo "Invalid choice"
    exit 1
  ;;
esac

cd "$OWN_DIR"
ce-dev start
ce-dev deploy