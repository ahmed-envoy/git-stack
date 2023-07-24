#! /usr/bin/env zsh

# get the current branch name, local only
BRANCH=$(git current)

# ignore master, main, release, develop
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ] || [ "$BRANCH" = "release" ] || [ "$BRANCH" = "develop" ]; then
    echo "git-spush: ignoring $BRANCH"
    exit 0
fi

git status $@

# if gh is not installed, exit 0
if ! command -v gh &> /dev/null; then
    exit 0
fi

local num=$(gh pr status --json 'number' --jq '.currentBranch.number')
if [ -n "$num" ]; then
    script -q /dev/null gh pr status | head -n7 
fi