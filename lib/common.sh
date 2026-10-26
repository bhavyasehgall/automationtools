#!/usr/bin/env bash
set -Eeuo pipefail

print_info()    { printf '[*] %s\n' "$*"; }
print_success() { printf '[+] %s\n' "$*"; }
print_warning() { printf '[!] %s\n' "$*" >&2; }
print_error()   { printf '[-] %s\n' "$*" >&2; }
die() { print_error "$*"; exit 1; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
get_timestamp() { date '+%Y-%m-%d_%H-%M-%S'; }
safe_filename() {
    local value="${1:-target}"
    value="${value//[^a-zA-Z0-9._-]/_}"
    value="${value##_}"
    value="${value%%_}"
    printf '%s' "${value:0:100}"
}
