#! /usr/bin/env zsh
CURRENT_BRANCH=$(git current)
git checkout -q $CURRENT_BRANCH
git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//'
git checkout -q -