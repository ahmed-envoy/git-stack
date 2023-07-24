#!/usr/bin/env zsh
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# if CURRENT_BRANCH is empty or HEAD, we're in a detached HEAD state and need to find the branch pointing to the same commit hash as HEAD
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "HEAD" ]]; then
    CURRENT_BRANCH=$(git branch --contains HEAD --sort=committerdate --format="%(refname:short)" | sed -n '2p' | awk '{print $1}' | head -n1)
fi 

echo $CURRENT_BRANCH