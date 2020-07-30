#!/bin/sh
# Push all generated content.

set -e

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)
PUBLIC_DIR="$OWN_DIR/public"

# for REPO in $(find "$PUBLIC_DIR" -maxdepth 1 -type d ! -name public); do
for REPO in "$PUBLIC_DIR"/*; do
  cd "$REPO"
  if [ -n "$(git diff)" ]; then
    git add .
    git commit -m "Travis CI - $(date)"
    git push
  fi
done