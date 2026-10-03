#!/usr/bin/env bash

set -Eeuo pipefail

TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

print_info() {
    echo "[*] $1"
}

print_success() {
    echo "[+] $1"
}

print_warning() {
    echo "[!] $1"
}

print_error() {
    echo "[-] $1" >&2
}

die() {
    print_error "$1"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

create_directory() {
    local directory="$1"

    mkdir -p "$directory"
}

get_timestamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

safe_filename() {
    echo "$1" | tr '/: ' '___'
}

run_command() {

    local description="$1"
    shift

    print_info "$description"

    if "$@"; then
        print_success "$description completed."
        return 0
    else
        print_error "$description failed."
        return 1
    fi
}
