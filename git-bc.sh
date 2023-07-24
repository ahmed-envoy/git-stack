#! /usr/bin/env zsh

local commit_message=""
local branch_name=""
local prefix=$(git config stack.prefix)

# If default prefix is not set, prompt the user to set one
if [ -z "$prefix" ]; then
    echo "No default prefix set."
    vared -p "Enter default prefix: " -c prefix
    git config stack.prefix "$prefix"
fi

# Check for the '-m' flag and capture the commit message
# Check for the '-m' flag
local has_message_flag=false
for arg in "$@"; do
    if [ "$arg" = "-m" ]; then
        has_message_flag=true
    elif $has_message_flag; then
        commit_message="$commit_message $arg"
        has_message_flag=false
    fi
done

echo "commit_message: $commit_message"
# If the '-m' flag was not provided, prompt for the commit message
if [ -z "$commit_message" ]; then
    vared -p "Enter commit message: " -c commit_message
fi

if [ -z "$commit_message" ]; then
    echo "No commit message provided."
    exit 1
fi

# trim leading spaces on commit_message
commit_message=$(echo "$commit_message" | sed -e 's/^[[:space:]]*//')

# trim trailing spaces on commit_message
commit_message=$(echo "$commit_message" | sed -e 's/[[:space:]]*$//')

# trim quotation marks on commit_message
commit_message=$(echo "$commit_message" | sed -e 's/^"//' -e 's/"$//')

# Replace special characters and spaces in the commit message with underscores
branch_name=$(echo "$commit_message" | tr -s '[:space:]' '_' | tr -dc '[:alnum:]_' | sed 's/_*$//')

if [ -z "$branch_name" ]; then
    echo "No branch name generated."
    exit 1
fi

branch_prefix=$(eval echo $prefix)
full_branch_name="$branch_prefix-$branch_name"
echo "Creating branch $full_branch_name"
# Create a new branch from the commit message
git checkout -b "$full_branch_name"

# Create the commit with the given commit message
git commit $@
