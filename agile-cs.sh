#!/bin/bash

DIRECTORY=".gitlinker"
FILE_PATH="$DIRECTORY/branch_ticket_map"

load_persister() {
    if [ ! -d "$DIRECTORY" ]; then
        mkdir -p "$DIRECTORY"
        touch "$FILE_PATH"
    fi
}

link_branch() {
    local BRANCH_NAME=$1
    local URL=$2
    echo "$BRANCH_NAME=$URL" >> "$FILE_PATH"
    echo "Linked the branch '$BRANCH_NAME' with '$URL'"
}

get_url() {
    local BRANCH=$1
    local URL=$(grep "^$BRANCH=" "$FILE_PATH" | cut -d '=' -f 2)

    echo "$URL"
}

get_git_branch() {
    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: Not inside a Git repository or failed to retrieve branch name."
        exit 1
    fi
    echo "$branch_name"
}

handle_add_link() {
    local branch=$(get_git_branch)
    local ticket=""

    while getopts ":b:t:" opt; do
        case $opt in
            b)
                branch="$OPTARG"
                ;;
            t)
                ticket="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG"
                exit 1
                ;;
        esac
    done

    if [ -z "$ticket" ]; then
        echo "Error: Please specify the url of your ticket using -t option."
        exit 1
    fi

    load_persister
    link_branch "$branch" "$ticket"
}

handle_open_link() {
    local branch=$(get_git_branch)

    while getopts ":b:" opt; do
        case $opt in
            b)
                branch="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG"
                exit 1
                ;;
        esac
    done

    load_persister
    local ticket=$(get_url "$branch") 

    if [ -z $ticket ]; then
        echo "Ticket not found."
        exit 1
    fi

    echo "The value for '$branch' is '$ticket'."
}

main() {
    local command="$1"
    shift

    if [ -z "$command" ]; then
        echo "Please specify the command [attachTicket|openTicket]."
        exit 1
    fi

    case "$command" in
        attachTicket)
            handle_add_link "$@"
            ;;
        openTicket)
            handle_open_link "$@"
            ;;
        *)
            echo "Unknown command. [attachTicket|openTicket]."
            exit 1
            ;;
    esac
}

main "$@"


