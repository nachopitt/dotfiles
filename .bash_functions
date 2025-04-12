#!/usr/bin/env bash

#######################################################################
#                          bash functions                             #
#######################################################################

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
