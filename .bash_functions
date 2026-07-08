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
    elif command -v clip.exe >/dev/null 2>&1; then
        echo -n "$text" | clip.exe
    elif command -v xclip >/dev/null 2>&1; then
        printf '%s' "$text" | xclip -selection clipboard >/dev/null 2>&1 &
    elif [ -e /dev/clipboard ]; then
        echo -n "$text" > /dev/clipboard
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

password-generator() {
    local length=10
    local lower_count=""
    local upper_count=""
    local number_count=""
    local special_count=""
    local original_lower_count
    local original_upper_count
    local original_number_count
    local original_special_count
    local start_with=""
    local explicit_counts=false
    local exact_mode=false
    local copy_to_clipboard=false
    local lower_chars='abcdefghijklmnopqrstuvwxyz'
    local upper_chars='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local number_chars='0123456789'
    local special_chars='!@#$%^&*()_+=-?/'
    local enabled_lower=true
    local enabled_upper=true
    local enabled_number=true
    local enabled_special=true
    local required_count
    local filler_count
    local remaining_length
    local password=""
    local body=""
    local combined_pool=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--length)
                length="$2"
                shift 2
                ;;
            -c|--chars|--lower)
                lower_count="$2"
                explicit_counts=true
                shift 2
                ;;
            -u|--CHARS|--upper)
                upper_count="$2"
                explicit_counts=true
                shift 2
                ;;
            -d|--numbers|--digits)
                number_count="$2"
                explicit_counts=true
                shift 2
                ;;
            -s|--special|--special-chars)
                special_count="$2"
                explicit_counts=true
                shift 2
                ;;
            --start-with)
                start_with="$2"
                shift 2
                ;;
            -x|--exact)
                exact_mode=true
                shift
                ;;
            -p|--copy)
                copy_to_clipboard=true
                shift
                ;;
            -h|--help)
                cat <<'EOF'
Usage: password-generator [options]

Options:
  -l, --length N           Total password length. Default: 10
  -c, --chars N            Minimum lowercase letters to include
      --lower N            Alias for --chars
  -u, --CHARS N            Minimum uppercase letters to include
      --upper N            Alias for --CHARS
  -d, --numbers N          Minimum digits to include
      --digits N           Alias for --numbers
  -s, --special N          Minimum special characters to include
      --special-chars N    Alias for --special
      --start-with TYPE    Force first character class: char, CHAR, number, special
  -x, --exact              Require exact requested counts with no filler characters
  -p, --copy               Copy the generated password to the clipboard
  -h, --help               Show this help text

Examples:
  password-generator --length 20 -c 4 -u 4 -d 4 -s 2
  password-generator --length 16 -d 6 -s 2 --start-with CHAR --copy
  password-generator --length 10 -c 4 -u 2 -d 2 -s 2 --exact
EOF
                return 0
                ;;
            *)
                echo "Error: Unknown option '$1'." >&2
                return 1
                ;;
        esac
    done

    for value_name in length lower_count upper_count number_count special_count; do
        local value="${!value_name}"

        if [[ -n "$value" && ! "$value" =~ ^[0-9]+$ ]]; then
            echo "Error: ${value_name} must be a non-negative integer." >&2
            return 1
        fi
    done

    if [[ "$length" -lt 1 ]]; then
        echo "Error: length must be at least 1." >&2
        return 1
    fi

    if $explicit_counts; then
        lower_count=${lower_count:-0}
        upper_count=${upper_count:-0}
        number_count=${number_count:-0}
        special_count=${special_count:-0}

        original_lower_count=$lower_count
        original_upper_count=$upper_count
        original_number_count=$number_count
        original_special_count=$special_count

        enabled_lower=false
        enabled_upper=false
        enabled_number=false
        enabled_special=false

        [[ "$lower_count" -gt 0 ]] && enabled_lower=true
        [[ "$upper_count" -gt 0 ]] && enabled_upper=true
        [[ "$number_count" -gt 0 ]] && enabled_number=true
        [[ "$special_count" -gt 0 ]] && enabled_special=true
    else
        lower_count=0
        upper_count=0
        number_count=0
        special_count=0
        original_lower_count=0
        original_upper_count=0
        original_number_count=0
        original_special_count=0
    fi

    if $exact_mode && ! $explicit_counts; then
        echo "Error: --exact requires explicit character counts." >&2
        return 1
    fi

    case "$start_with" in
        "")
            ;;
        char)
            enabled_lower=true
            ;;
        CHAR)
            enabled_upper=true
            ;;
        number)
            enabled_number=true
            ;;
        special)
            enabled_special=true
            ;;
        *)
            echo "Error: --start-with must be one of: char, CHAR, number, special." >&2
            return 1
            ;;
    esac

    if $exact_mode; then
        case "$start_with" in
            char)
                [[ "$original_lower_count" -eq 0 ]] && {
                    echo "Error: --exact cannot use --start-with char unless lowercase count is greater than 0." >&2
                    return 1
                }
                ;;
            CHAR)
                [[ "$original_upper_count" -eq 0 ]] && {
                    echo "Error: --exact cannot use --start-with CHAR unless uppercase count is greater than 0." >&2
                    return 1
                }
                ;;
            number)
                [[ "$original_number_count" -eq 0 ]] && {
                    echo "Error: --exact cannot use --start-with number unless digit count is greater than 0." >&2
                    return 1
                }
                ;;
            special)
                [[ "$original_special_count" -eq 0 ]] && {
                    echo "Error: --exact cannot use --start-with special unless special count is greater than 0." >&2
                    return 1
                }
                ;;
        esac
    fi

    if ! $enabled_lower && ! $enabled_upper && ! $enabled_number && ! $enabled_special; then
        echo "Error: No character groups enabled." >&2
        return 1
    fi

    combined_pool=""
    $enabled_lower && combined_pool+="$lower_chars"
    $enabled_upper && combined_pool+="$upper_chars"
    $enabled_number && combined_pool+="$number_chars"
    $enabled_special && combined_pool+="$special_chars"

    remaining_length=$length

    if [[ -n "$start_with" ]]; then
        case "$start_with" in
            char)
                password+=$(_password_generator_random_char "$lower_chars")
                [[ "$lower_count" -gt 0 ]] && ((lower_count--))
                ;;
            CHAR)
                password+=$(_password_generator_random_char "$upper_chars")
                [[ "$upper_count" -gt 0 ]] && ((upper_count--))
                ;;
            number)
                password+=$(_password_generator_random_char "$number_chars")
                [[ "$number_count" -gt 0 ]] && ((number_count--))
                ;;
            special)
                password+=$(_password_generator_random_char "$special_chars")
                [[ "$special_count" -gt 0 ]] && ((special_count--))
                ;;
        esac

        ((remaining_length--))
    fi

    required_count=$((lower_count + upper_count + number_count + special_count))

    if [[ "$required_count" -gt "$remaining_length" ]]; then
        echo "Error: required character counts exceed the requested password length." >&2
        return 1
    fi

    body+=$(_password_generator_build_chunk "$lower_chars" "$lower_count")
    body+=$(_password_generator_build_chunk "$upper_chars" "$upper_count")
    body+=$(_password_generator_build_chunk "$number_chars" "$number_count")
    body+=$(_password_generator_build_chunk "$special_chars" "$special_count")

    filler_count=$((remaining_length - required_count))

    if $exact_mode && [[ "$filler_count" -ne 0 ]]; then
        echo "Error: --exact requires length to match the requested character counts exactly." >&2
        return 1
    fi

    body+=$(_password_generator_build_chunk "$combined_pool" "$filler_count")

    if [[ -n "$body" ]]; then
        password+=$(printf '%s' "$body" | fold -w1 | shuf | tr -d '\n')
    fi

    if $copy_to_clipboard; then
        _git_branch_set_clipboard "$password"
    fi

    echo "$password"
}

_password_generator_random_char() {
    local char_pool="$1"
    local pool_length="${#char_pool}"
    local random_number

    random_number=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
    printf '%s' "${char_pool:random_number % pool_length:1}"
}

_password_generator_build_chunk() {
    local char_pool="$1"
    local count="$2"
    local chunk=""
    local i

    for ((i = 0; i < count; i++)); do
        chunk+=$(_password_generator_random_char "$char_pool")
    done

    printf '%s' "$chunk"
}
