#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/automationtools.sh"
pass=0 fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

check() {
    local name="$1"; shift
    if "$@" >"$tmp/stdout" 2>"$tmp/stderr"; then
        printf 'PASS: %s\n' "$name"; pass=$((pass+1))
    else
        printf 'FAIL: %s\n' "$name"; cat "$tmp/stderr" >&2; fail=$((fail+1))
    fi
}
reject() {
    local name="$1"; shift
    if "$@" >"$tmp/stdout" 2>"$tmp/stderr"; then
        printf 'FAIL: %s (unexpected success)\n' "$name"; fail=$((fail+1))
    else
        printf 'PASS: %s\n' "$name"; pass=$((pass+1))
    fi
}
check "help exits successfully" bash "$SCRIPT" --help
check "version exits successfully" bash "$SCRIPT" --version
reject "unknown option rejected" bash "$SCRIPT" --not-a-real-option
reject "invalid Nmap mode rejected" bash "$SCRIPT" -t example.com -m nmap --nmap-mode stealth
reject "directory without URL rejected" bash "$SCRIPT" -t example.com -m directory
reject "malformed domain rejected" bash "$SCRIPT" -t 'bad..example' -m subdomains
reject "missing module rejected" bash "$SCRIPT" -t example.com
# Validate library functions in a subshell with die mapped to a normal exit.
check "valid domain accepted" bash -c 'source "$1/lib/common.sh"; source "$1/lib/validation.sh"; validate_domain example.com' _ "$ROOT"
check "valid local URL accepted" bash -c 'source "$1/lib/common.sh"; source "$1/lib/validation.sh"; validate_url http://127.0.0.1:8000' _ "$ROOT"
reject "invalid IPv4 rejected" bash -c 'source "$1/lib/common.sh"; source "$1/lib/validation.sh"; validate_host 999.1.1.1' _ "$ROOT"
printf '\nResults: %d passed, %d failed\n' "$pass" "$fail"
((fail == 0))
