#!/bin/sh
# Prepare all generated content.
# For GitHub Actions the $GITHUB_TOKEN environment variable is not available so
# the push command needs to be done in your CI, not in this script like Travis.

set -e

#OWN_DIR=$(dirname "$0")
#cd "$OWN_DIR" || exit 1
#OWN_DIR=$(git rev-parse --show-toplevel)
#cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)
PUBLIC_DIR="$OWN_DIR/public"

# for REPO in $(find "$PUBLIC_DIR" -maxdepth 1 -type d ! -name public); do
for REPO in "$PUBLIC_DIR"/*; do
  cd "$REPO"
  echo "Preparing path $(pwd -P)"
  if [ -n "$(git diff)" ] || [ -n "$( git ls-files . --exclude-standard --others)" ]; then
    git pull --ff-only
    git add .
    git commit -m "GitHub Actions - $(date)"
  fi
done
