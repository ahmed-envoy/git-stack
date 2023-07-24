#! /usr/bin/env zsh

HEAD=${1:-HEAD}
BRANCH=$(git rev-parse --abbrev-ref $HEAD)
ESCAPED_REPLACE=$(printf '%s\n' "$BRANCH" | sed -e 's/[\/&]/\\&/g')
# output descendants of HEAD and filter out current branch
# git branch --contains $HEAD --sort=committerdate --format="%(refname:short)" | sed -n '1,$p' | awk '{print $1}'
git branch --contains $HEAD --sort=committerdate --format="%(refname:short)" | sed -n '1,$p' | awk '{print $1}' | sed "/$ESCAPED_REPLACE/d" 