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
