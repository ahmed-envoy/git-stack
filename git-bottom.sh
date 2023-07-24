#! /usr/bin/env zsh
RED='\033[0;31m'
PROTECTED=$(git config "stack.protected-branch")

tmpfile=$(mktemp /tmp/git-bottom.XXXXXX)

function dontLeaveMeDetached() {
    # if we are on a detached head, before a protected branch
    # then we are at the bottom of the stack
    # but not the branch, so we need to move to the next branch
    # we need to loop through git stack next until we are on a branch
    local head=$(git rev-parse --symbolic-full-name HEAD)
    while [[ "$head" == "HEAD" ]]; do
        echo "${RED}detached HEAD, switch back to child"
        git stack next
        head=$(git rev-parse --symbolic-full-name HEAD)
    done
}

# note: no unprotected parent commit; to traverse protected commits, pass \`--protected\`
while true; do
    git stack prev -n >$tmpfile 2>&1
    if [[ $(cat $tmpfile) =~ "aborting" ]]; then
        break
    fi

    # if the output contains the protected branch, then we are at the bottom of the stack
    if [[ $(cat $tmpfile) =~ "$PROTECTED" ]]; then
        dontLeaveMeDetached
        git status
        break
    fi

    # if the output implies we are on a protected branch, then we are at the bottom of the stack
    if [[ $(cat $tmpfile) =~ "note: no unprotected parent commit; to traverse protected commits, pass \`--protected\`" ]]; then
        dontLeaveMeDetached

        git status
        break
    fi
    git stack prev
done
