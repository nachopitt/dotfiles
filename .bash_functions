#!/usr/bin/env bash

#######################################################################
#                          bash functions                             #
#######################################################################

quiltp() {
    local args=("$@")
    local name="${args[0]}"
    local patch_dir="patches/$name"
    local pc_dir=".pc/$name"

    if [[ -z "$name" ]]; then
        echo "Usage: quiltp <namespace> <quilt arguments...>" >&2
        return 1
    fi

    if [[ ! -d "$patch_dir" ]]; then
        echo "Error: Patch directory '$patch_dir' does not exist." >&2
        return 1
    fi

    QUILT_PATCHES="$patch_dir" QUILT_PC="$pc_dir" quilt "${args[@]:1}"
}

bootstrap() {
    local args=("$@")

    if [[ "${args[0]}" == "patch" ]]; then
        if [[ -d "patches/${args[1]}" ]]; then
            QUILT_PATCHES="patches/${args[1]}" QUILT_PC=".pc/${args[1]}" quilt push -a
        else
            echo "patch queue ${args[1]} doesn't exist"

            return 1
        fi
    else
        local add_worktree=true

        for arg in "$@"; do
            if [[ "$arg" == "-w" ]]; then
                add_worktree=false
                break
            fi
        done

        if [[ "${args[0]}" == "clone" || "${args[0]}" == "init" ]] && $add_worktree; then
            args+=("-w" "$PWD")
        fi

        yadm --yadm-dir "$PWD/.config/yadm" --yadm-data "$PWD/.local/share/yadm" "${args[@]}"
    fi

    return 0
}

if [ -n "$TMUX" ]; then
    refresh() {
        eval $(tmux show-environment -s SSH_AUTH_SOCK)
        eval $(tmux show-environment -s SSH_AGENT_PID)
        eval $(tmux show-environment -s SSH_CONNECTION)

        return 0
    }
else
    refresh() {
        return 0
    }
fi

vim() {
    if [ $# -eq 0 ]; then
        command vim
        return
    fi

    for file in "$@"; do
        if yadm ls-files --error-unmatch "$file" >/dev/null 2>&1; then
            yadm enter vim "$@"
            return
        fi
    done

    command vim "$@"
}

nvim() {
    if [ $# -eq 0 ]; then
        command nvim
        return
    fi

    for file in "$@"; do
        if yadm ls-files --error-unmatch "$file" >/dev/null 2>&1; then
            yadm enter nvim "$@"
            return
        fi
    done

    command nvim "$@"
}

# This function is used to open a file in the default editor
# If the file is not tracked by yadm, it will open in the default editor
# If the file is tracked by yadm, it will open in the yadm editor
# Usage: edit <file>
edit() {
    if [ $# -eq 0 ]; then
        command edit
        return
    fi

    for file in "$@"; do
        if yadm ls-files --error-unmatch "$file" >/dev/null 2>&1; then
            yadm enter edit "$@"
            return
        fi
    done

    command edit "$@"
}

# Parse default.xml and print manifest path (or name) and git HEAD revision
layer_revs() {
    project_paths=$(grep "<project" default.xml | sed -nE 's/.*name="([^"]*)".*path="([^"]*)".*/\2/p; s/.*name="([^"]*)".*/\1/p')

    for path in $project_paths; do
        pushd yocto/$path > /dev/null

        hash=$(git rev-parse HEAD)
        printf "%-20s %s\n" "$path:" "$hash"

        popd > /dev/null
    done
}

# Parse default.xml and print manifest path (or name) and manifest revision
manifest_revs() {
    while read -r line; do
        name=$(echo "$line" | sed -nE 's/.*name="([^"]*)".*/\1/p')
        path=$(echo "$line" | sed -nE 's/.*path="([^"]*)".*/\1/p')
        revision=$(echo "$line" | sed -nE 's/.*revision="([^"]*)".*/\1/p')

        [ -z "$path" ] && path="$name"

        printf "%-20s %s\n" "$path:" "$revision"
    done < <(grep "<project" default.xml)
}

diff_manifest_layer_revs() {
    vimdiff <(manifest_revs) <(layer_revs)
}


check_git_status_in_subdirs() {
    for dir in */; do
        if [ -d "$dir/.git" ]; then
            echo "Checking status in $dir"
            (cd "$dir" && git status)
            echo ""
        fi
    done
}

rgf() {
    if [ $# -eq 0 ]; then
        echo "Usage: rgf <pattern> [directory]" >&2
        return 1
    fi

    rg --files --no-ignore --hidden --binary "${2:-.}" | rg "$1"
}

# Helper: Get clipboard content across platforms
_git_branch_get_clipboard() {
    if command -v pbpaste >/dev/null 2>&1; then
        pbpaste
    elif command -v wl-paste >/dev/null 2>&1; then
        wl-paste
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -o
    elif [ -e /dev/clipboard ]; then
        cat /dev/clipboard
    elif command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command "Get-Clipboard" 2>/dev/null | tr -d '\r'
    else
        echo ""
    fi
}

# Helper: Set clipboard content across platforms
_git_branch_set_clipboard() {
    local text="$1"
    if command -v pbcopy >/dev/null 2>&1; then
        echo -n "$text" | pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then
        echo -n "$text" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
        echo -n "$text" | xclip -selection clipboard
    elif [ -e /dev/clipboard ]; then
        echo -n "$text" > /dev/clipboard
    elif command -v clip.exe >/dev/null 2>&1; then
        echo -n "$text" | clip.exe
    fi
}

# Main function you can call directly
git-branch-name() {
    local input_str

    # 1. Get input (argument or clipboard)
    if [ $# -gt 0 ]; then
        input_str="$*"
    else
        input_str=$(_git_branch_get_clipboard)
    fi

    # Strip Windows carriage returns if any
    input_str=$(echo "$input_str" | tr -d '\r')

    if [ -z "$input_str" ]; then
        echo "Error: No input provided and clipboard is empty." >&2
        return 1
    fi

    # 2. Extract JIRA ticket (case-insensitive: e.g. ABC-1234 or JIRA-99)
    local jira_ticket
    jira_ticket=$(echo "$input_str" | grep -oEi '\b[a-zA-Z]+-[0-9]+\b' | head -n 1 | tr 'a-z' 'A-Z')

    # 3. Clean description: remove the Jira ticket, strip non-alphanumeric, convert to lower, join with dashes
    local cleaned_str
    if [ -n "$jira_ticket" ]; then
        # Remove JIRA ticket from description (case-insensitive)
        cleaned_str=$(echo "$input_str" | sed -E "s/\\b$jira_ticket\\b//I")
    else
        cleaned_str="$input_str"
    fi

    # Replace non-alphanumeric with spaces
    cleaned_str=$(echo "$cleaned_str" | sed -E 's/[^a-zA-Z0-9]+/ /g')

    # Lowercase
    cleaned_str=$(echo "$cleaned_str" | tr 'A-Z' 'a-z')

    # Trim leading and trailing spaces
    cleaned_str=$(echo "$cleaned_str" | sed -E 's/^ +//; s/ +$//')

    # Replace remaining spaces with dashes
    local description
    description=$(echo "$cleaned_str" | tr ' ' '-')

    # 4. Construct final branch name
    local branch_name
    if [ -n "$jira_ticket" ]; then
        branch_name="${description}/${jira_ticket}"
    else
        branch_name="${description}"
    fi

    # Clean multiple dashes/slashes, leading/trailing dashes/slashes
    branch_name=$(echo "$branch_name" | sed -E 's/-+/-/g' | sed -E 's/\/+/\//g' | sed -E 's/^[-/]+//; s/[-/]+$//')

    if [ -z "$branch_name" ]; then
        echo "Error: Could not format a valid branch name from the input." >&2
        return 1
    fi

    # 5. Copy back to clipboard and output
    _git_branch_set_clipboard "$branch_name"
    echo "$branch_name"
}
