#! /usr/bin/env zsh

PARENT_BRANCH=$(git parent)
CURRENT_BRANCH=$(git current)
immediate_descendantS=$(git ctx) # space separated list of branches

# if gh is not installed exit 1
if ! command -v gh &>/dev/null; then
    echo "error: gh not installed"
    exit 1
fi

prbodyfile=$(mktemp /tmp/git-prcomment.XXXXXXXXX)
tab=""

: '
We want the output of the PR body to be structured as nested markdown unordered list

Current dependencies on/for this PR:

* **PR #<parent_PR_number>
  * **PR #<current_PR_number> 👈
    * **PR #<immediate_descendant_PR_number>
    * **PR #<immediate_descendant_PR_number>
    * **PR #<immediate_descendant_PR_number>
'

echo "Current dependencies on/for this PR:" >>$prbodyfile

# stash
git stash -q

# if there is a parent branch and it is not a protected branch, then output it to the PR body file
if [ -n "$PARENT_BRANCH" ] && [ "$PARENT_BRANCH" != "master" ] && [ "$PARENT_BRANCH" != "main" ] && [ "$PARENT_BRANCH" != "release" ] && [ "$PARENT_BRANCH" != "develop" ]; then
    # multiline echo
    git checkout -q $PARENT_BRANCH

    # get the parent branch PR number from the temp file
    PARENT_PR_NUMBER=$(gh pr status --json 'url,number' --jq '.currentBranch.number')
    # if there is a parent PR number, then output it to the PR body file
    if [ -n "$PARENT_PR_NUMBER" ]; then
        echo "* **PR #${PARENT_PR_NUMBER}**" >>$prbodyfile
        tab="  "
    fi
fi

git checkout -q $CURRENT_BRANCH

# get the current branch PR number from the temp file
CURRENT_PR_NUMBER=$(gh pr status --json 'url,number' --jq '.currentBranch.number')

# if there is no current PR number, then exit 1 and output an error message
if [ -z "$CURRENT_PR_NUMBER" ]; then
    echo "error: no current PR number"
    echo "run \`gh pr create --fill\` to create a PR"
    exit 1
fi

# output the current PR number to the PR body file
echo "${tab}* **PR #${CURRENT_PR_NUMBER}** 👈" >>$prbodyfile

# append two spaces to the tab
tab="${tab}  "

# for each immediate descendant, get the PR number and output it to the PR body file

echo "debug: immediate_descendantS: $immediate_descendantS"
IFS=" " read -rA dob <<<"$immediate_descendantS"
for descendant in "${dob[@]}"; do
    if [ -z "$descendant" ]; then
        continue
    fi
    git checkout -q $descendant
    local descendant_pr_number=$(gh pr status --json 'url,number' --jq '.currentBranch.number')
    # if the descendant PR number is empty, then skip it
    if [ -z "$descendant_pr_number" ]; then
        continue
    fi
    echo "${tab}* **PR #${descendant_pr_number}**" >>$prbodyfile
done

git checkout -q $CURRENT_BRANCH

# pop
git stash pop -q

cat $prbodyfile

# use the gh graphql api to find a comment on the current PR that contains the text "Current dependencies on/for this PR:"
# if there is a comment, then update it
# if there is no comment, then create one
commentid=$(gh api graphql -F owner='{owner}' -F repo='{repo}' -F pr_number=${CURRENT_PR_NUMBER} -f query='query($owner: String!, $repo: String!, $pr_number: Int!) { repository(owner: $owner, name: $repo) { pullRequest(number: $pr_number) { comments(first: 100) { nodes { id body } } } } }' --jq '.data.repository.pullRequest.comments.nodes | map(select(.body | contains("Current dependencies on/for this PR:"))) | .[0].id')

if [ -n "$commentid" ]; then
    gh api graphql -F commentid=$commentid -F body=@$prbodyfile -f query='mutation($commentid: ID!, $body: String!) { updateIssueComment(input: { id: $commentid, body: $body }) { issueComment { id } } }'
else
    gh pr comment $CURRENT_PR_NUMBER -F $prbodyfile
fi

rm $prbodyfile
