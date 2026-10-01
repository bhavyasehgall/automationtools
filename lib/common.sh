#!/usr/bin/env bash

# Prevent accidental re-loading
if [[ "${AUTOMATIONTOOLS_COMMON_LOADED:-false}" == true ]]; then
    return
fi

AUTOMATIONTOOLS_COMMON_LOADED=true

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="$PROJECT_ROOT/results"

RUN_DIR=""

info() {
    echo -e "${BLUE}[*]${NC} $1"
}

success() {
    echo -e "${GREEN}[+]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[-]${NC} $1" >&2
}

die() {
    error "$1"
    exit 1
}

debug() {
    if [[ "${VERBOSE:-false}" == true ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

timestamp_file() {
    date '+%Y%m%d_%H%M%S'
}

sanitize_filename() {

    local value="$1"

    value="${value#http://}"
    value="${value#https://}"

    echo "$value" |
        tr '/:?' '_' |
        tr -cd '[:alnum:]_.-'
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_banner() {

    echo
    echo "=============================================="
    echo "           AutomationTools v2.0"
    echo "      Reconnaissance Automation Suite"
    echo "=============================================="
    echo
}

init_results() {

    local target_name="${1:-automation}"
    local timestamp_value

    timestamp_value="$(timestamp_file)"

    mkdir -p "$RESULTS_ROOT"

    RUN_DIR="$RESULTS_ROOT/${target_name}_${timestamp_value}"

    mkdir -p "$RUN_DIR"

    debug "Created result directory: $RUN_DIR"
}

save_metadata() {

    local target="$1"

    cat > "$RUN_DIR/metadata.txt" <<EOF
AutomationTools
===============

Target: $target
Started: $(timestamp)
Version: ${VERSION:-unknown}
EOF
}

require_file() {

    local file="$1"

    [[ -f "$file" ]] || die "File does not exist: $file"
}

require_directory() {

    local directory="$1"

    [[ -d "$directory" ]] ||
        die "Directory does not exist: $directory"
}

handle_error() {

    local exit_code="$?"

    if [[ "$exit_code" -ne 0 ]]; then
        error "Command failed with exit code $exit_code."
    fi
}
