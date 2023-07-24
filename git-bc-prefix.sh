#! /usr/bin/env zsh

local newPrefix="$1"
local prefix=$(git config stack.prefix)

# If default prefix is not set, prompt the user to set one
if [ -z "$newPrefix" ]; then
    echo "No prefix provided."
    echo "Usage: git bc prefix <prefix>"
    exit 1
fi

# if prefix already exists log that the prefix is changing
if [ -n "$prefix" ]; then
    echo "Changing prefix from $prefix to $newPrefix"
fi

git config stack.prefix "$newPrefix"
