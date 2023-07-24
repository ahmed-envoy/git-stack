#! /usr/bin/env zsh

PARENT=$(git parent)
CURRENT_PR_NUMBER=$(gh pr status --json 'url,number' --jq '.currentBranch.number')

# if there is no current PR number, then exit 1 and output an error message
if [ -z "$CURRENT_PR_NUMBER" ]; then
    gh pr create --base $PARENT --fill
else
    git fpush
fi

git prcomment