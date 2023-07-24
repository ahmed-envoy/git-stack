#! /usr/bin/env zsh

# get the current branch name, local only
BRANCH=$(git current)

# ignore master, main, release, develop
if [ "$BRANCH" = "HEAD" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ] || [ "$BRANCH" = "release" ] || [ "$BRANCH" = "develop" ]; then
    echo "git-spush: ignoring $BRANCH"
    exit 0
fi

# push to origin
echo "pushing to $BRANCH"
git push --force-with-lease origin $BRANCH