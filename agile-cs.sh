#!/bin/bash

DIRECTORY="$HOME/.gitlinker"
FILE_PATH=""

load_persister() {
    local REPO=$(get_git_repo)
    FILE_PATH="$DIRECTORY/branch_ticket_map_$REPO"
    if [ ! -d "$DIRECTORY" ]; then
        mkdir -p "$DIRECTORY"
        touch "$FILE_PATH"
    fi
}

link_branch() {
    local BRANCH_NAME=$1
    local URL=$2

    if grep -q "^$BRANCH_NAME=" "$FILE_PATH"; then
        sed -i.bak "s|^$BRANCH_NAME=.*|$BRANCH_NAME=$URL|" "$FILE_PATH"
    else
        echo "$BRANCH_NAME=$TICKET" >> "$FILE_PATH"
    fi

    echo "Linked the branch '$BRANCH_NAME' to '$URL'"
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

get_git_repo() {
    remote_url=$(git config --get remote.origin.url)
    repo_name=$(basename -s .git "$remote_url")

    echo "$repo_name"
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

    open_url $ticket
}

open_url() {
    local url="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        open "$url"
    elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
        xdg-open "$url"
    elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]]; then
        cmd.exe /c start "" "$url"
    elif [[ "$(expr substr $(uname -s) 1 9)" == "MINGW64_NT" ]]; then
        cmd.exe /c start "" "$url"
    else
        echo "Unsupported platform"
        exit 1
    fi
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


