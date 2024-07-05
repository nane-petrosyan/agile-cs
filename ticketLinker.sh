#!/bin/bash

declare -A kv_store
DIRECTORY="~/.gitlinker"
FILE_PATH="$DIRECTORY/branch_ticket_map"

create_persister() {
    if [ ! -d "$DIRECTORY" ]; then
        mkdir -p "$DIRECTORY"
        touch "$FILE_PATH"
    fi
}

load_kv_store() {
    if [ -f "$FILE_PATH" ]; then
        while IFS='=' read -r KEY VALUE; do
            kv_store["$KEY"]="$VALUE"
        done < "$FILE_PATH"
    fi
}

link_branch() {
    local BRANCH_NAME=$1
    local URL=$2
    echo "$BRANCH_NAME=$URL"
    kv_store["$BRANCH_NAME"="$URL"]
    echo "Linked the branch '$BRANCH_NAME' with '$URL'"
}

get_url() {
    local BRANCH=$1
    echo "The branch matches to ${kv_store[$KEY]}"
}

main() {
    local BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    echo "Opening the ticket for branch '$BRANCH_NAME'"
    get_url 
}

main
