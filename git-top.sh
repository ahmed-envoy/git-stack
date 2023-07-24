#! /usr/bin/env zsh

# keeps running git stack next until it reaches the end of the stack denoted the output
# if the output is `note: no child commit` that means it's the end of the stack

tmpfile=$(mktemp /tmp/git-bottom.XXXXXX)
while true; do
    git stack next -n >$tmpfile 2>&1
    # if it fails break
    if [[ $(cat $tmpfile) =~ "aborting" ]]; then
        break
    fi

    if [[ $(cat $tmpfile) =~ "note: no child commit" ]]; then
        git status
        break
    fi
    git stack next
done
