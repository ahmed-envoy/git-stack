#!/usr/bin/env zsh

BASE_BRANCH="${1}"
COMMIT_MSG="${2}"
CURRENT_BRANCH=$(git current)

if [ -z "$BASE_BRANCH" ]; then
    BASE_BRANCH=$(git parent)
fi

# if COMMIT_MSG is not set, use the first commit message of the current branch
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG=$(git log --oneline --format=%B --reverse --date-order ${BASE_BRANCH}..${CURRENT_BRANCH} | head -n 1)
fi

tmpfile=$(mktemp /tmp/git-squash.XXXXXXXXX)
# get all files changed in the current branch
git diff --name-only $BASE_BRANCH > $tmpfile

# reset the current branch to the base branch
git reset $(git merge-base ${BASE_BRANCH} ${CURRENT_BRANCH}) 

# add all files changed in the current branch stored in the temp file
cat $tmpfile | xargs git add

rm $tmpfile

# commit
git commit -m "$COMMIT_MSG"