#! /usr/bin/env zsh

# get the current branch name, local only
BRANCH=$(git current)

# echo "git-srun: running $BRANCH"
# ignore master, main, release, develop
if [ "$BRANCH" = "HEAD" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ] || [ "$BRANCH" = "release" ] || [ "$BRANCH" = "develop" ]; then
    # echo "git-srun: ignoring $BRANCH"
    exit 0
fi

# run whatever command the user passed in
"$@"