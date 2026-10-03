#!/usr/bin/env bash

# AutomationTools
# Shared utility functions

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RESULTS_BASE="${SCRIPT_DIR}/results"
RUN_TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

RUN_DIR=""

init_results() {
    local target="${1:-target}"

    mkdir -p "$RESULTS_BASE"

    local safe_target
    safe_target="$(sanitize_filename "$target")"

    RUN_DIR="${RESULTS_BASE}/${safe_target}_${RUN_TIMESTAMP}"

    mkdir -p "$RUN_DIR"
}

sanitize_filename() {
    local input="${1:-target}"

    printf '%s' "$input" |
        tr -c '[:alnum:]._- ' '_' |
        tr ' ' '_' |
        sed 's/_\{2,\}/_/g'
}

log_info() {
    printf '[INFO] %s\n' "$*"
}

log_success() {
    printf '[+] %s\n' "$*"
}

log_warning() {
    printf '[!] %s\n' "$*" >&2
}

log_error() {
    printf '[ERROR] %s\n' "$*" >&2
}

die() {
    log_error "$*"
    exit 1
}

debug() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        printf '[DEBUG] %s\n' "$*"
    fi
}

require_command() {
    local command_name="$1"

    command -v "$command_name" >/dev/null 2>&1 ||
        die "Required command not found: $command_name"
}

write_metadata_json() {
    local target="$1"
    local module="${2:-unknown}"

    [[ -n "$RUN_DIR" ]] ||
        die "Result directory has not been initialized."

    cat > "${RUN_DIR}/metadata.json" <<EOF
{
  "project": "AutomationTools",
  "version": "2.0.0",
  "target": "$(printf '%s' "$target" | sed 's/"/\\"/g')",
  "module": "$(printf '%s' "$module" | sed 's/"/\\"/g')",
  "timestamp": "${RUN_TIMESTAMP}",
  "hostname": "$(hostname)",
  "user": "${USER:-unknown}",
  "os": "$(uname -s)",
  "kernel": "$(uname -r)",
  "architecture": "$(uname -m)"
}
EOF
}

create_module_dir() {
    local module="$1"

    [[ -n "$RUN_DIR" ]] ||
        die "Result directory has not been initialized."

    mkdir -p "${RUN_DIR}/${module}"

    printf '%s\n' "${RUN_DIR}/${module}"
}
