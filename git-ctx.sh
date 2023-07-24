#! /usr/bin/env zsh

HEAD=${1:-HEAD}
CURRENT_BRANCH=$(git current)

# declare associative array descendants
declare -A descendants

function printDescendants() {
    for i v in "${(@kv)descendants}"; do
        echo "branch: $i"
        echo "direct-descendants: $v"
        echo
    done
    return 0
}

function getDescendants() {
    branch=$1
    local _descendants=($(git-descendants.sh $branch))
    # Create an indexed array to store the descendants
    local -a descendants_array

    for dbranch in $_descendants; do
        # Append dbranch to descendants_array
        descendants_array+=("$dbranch")
    done

    # Assign the indexed array to descendants[$branch]
    descendants[$branch]=${descendants_array}

    return 0
}

getDescendants $CURRENT_BRANCH

# for each descendant of CURRENT_BRANCH, get its descendants and update descendants[CURRENT_BRANCH] to only include direct descendants
for dbranch in ${descendants[$CURRENT_BRANCH]}; do
   # Split the space-separated dbranch into an array
   IFS=" " read -rA dbranch_array <<< "$dbranch"
   
   # Iterate over the individual branch names within dbranch
   for branch_name in "${dbranch_array[@]}"; do
        # echo "branch_name: $branch_name"
        getDescendants $branch_name
   done
done

# for each key in descendants, we want to remove branches in the value list which are not direct descendants of key
for i v in "${(@kv)descendants}"; do
    local key="$i"
    IFS=" " read -rA value <<< "$v"
    local -a direct_descendants=(${value[@]})

    # Iterate over the value list
    for branch in "${value[@]}"; do
        descendants_of_branch=${descendants[$branch]}
        # if there are descendants of branch, then each of those descendants are not direct descendants of key
        # for each descendant of branch, remove it from direct_descendants
        if [ -n "$descendants_of_branch" ]; then
            IFS=" " read -rA dob <<< "$descendants_of_branch"
            for descendant in "${dob[@]}"; do
                # echo "descendant: $descendant removed from $key"
                direct_descendants=(${direct_descendants[@]/$descendant})
            done
        fi
    done

    # Update the value list with the direct descendants
    descendants[$key]=${direct_descendants}
done

# print direct descendants of CURRENT_BRANCH
echo ${descendants[$CURRENT_BRANCH]}