#! /usr/bin/env zsh

# get the current branch name, local only
BRANCH=$(git current)
CURRENT_SHA=$(git rev-parse --short HEAD)
DETACHED=$(git branch --show-current | wc -l)

if [ "$DETACHED" -eq 1 ]; then
    BRANCH="HEAD"
fi

# echo "git-srun: running $BRANCH"
# ignore master, main, release, develop
if [ "$BRANCH" = "HEAD" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ] || [ "$BRANCH" = "release" ] || [ "$BRANCH" = "develop" ]; then
    # echo "git-srun: ignoring $BRANCH"
    exit 0
fi

# checkout the current branch
git checkout $BRANCH

# catch exit codes so that we don't exit if the command fails
set +e

# run whatever command the user passed in
"$@"

exitCode=$?

# checkout the previous head
git checkout -q $CURRENT_SHA

# exit with the exit code of the command
exit $exitCode