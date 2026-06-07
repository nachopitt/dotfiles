#!/usr/bin/env bash
# Safe ssh-agent startup for interactive shells only.
# Usage: source this file from your ~/.bashrc or call it interactively.

case "$-" in *i*) ;; *) return ;; esac

# Skip on CI or explicitly excluded hosts (customize patterns)
[[ -n "$CI" || -n "$GITHUB_ACTIONS" ]] && return
EXCLUDE_PATTERNS=("prod" "production" "prod-server")
HOSTNAME=$(hostname)
for p in "${EXCLUDE_PATTERNS[@]}"; do
    [[ "$HOSTNAME" == *"$p"* ]] && return
done

SSH_ENV="$HOME/.ssh/.agent_env"

start_agent() {
    echo "Initialising new SSH agent..."
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    printf 'export SSH_AUTH_SOCK=%s\nexport SSH_AGENT_PID=%s\n' "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" > "$SSH_ENV"
    chmod 600 "$SSH_ENV"
    # Add only keys explicitly allowed via SSH_ADD_KEYS (space-separated paths)
    if [[ -n "${SSH_ADD_KEYS:-}" ]]; then
        for key in $SSH_ADD_KEYS; do
            [[ -f "$key" ]] && /usr/bin/ssh-add -q "$key" || true
        done
    fi
    echo "succeeded"
}

# Source existing agent env if valid, else start a new one
if [[ -f "$SSH_ENV" ]]; then
    # shellcheck disable=SC1090
    . "$SSH_ENV" >/dev/null 2>&1
    if ! ps -p "${SSH_AGENT_PID:-0}" >/dev/null 2>&1; then
        start_agent
    fi
else
    start_agent
fi

# Create a stable hardlink socket so multiple shells can share it (best-effort)
if [[ -S "${SSH_AUTH_SOCK:-}" ]]; then
    MYSOCK="/tmp/ssh_agent.${RANDOM}.sock"
    ln -f "${SSH_AUTH_SOCK}" "$MYSOCK" 2>/dev/null || true
    export SSH_AUTH_SOCK="$MYSOCK"
fi

end_agent() {
    if [[ -e "$SSH_AUTH_SOCK" ]]; then
        nhard=$(stat -c '%h' "$SSH_AUTH_SOCK" 2>/dev/null || echo 0)
        if [[ "$nhard" -eq 2 ]]; then
            rm -f "$SSH_ENV"
            /usr/bin/ssh-agent -k >/dev/null 2>&1 || true
        fi
        rm -f "$SSH_AUTH_SOCK" 2>/dev/null || true
    fi
}
trap end_agent EXIT
