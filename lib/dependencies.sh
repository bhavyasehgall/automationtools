#!/usr/bin/env bash
set -Eeuo pipefail

REQUIRED_TOOLS=("bash")
OPTIONAL_TOOLS=("nmap" "subfinder" "assetfinder" "findomain" "gobuster" "dirsearch")

check_dependencies() {
    local missing=0 tool
    printf '\nDependency Check\n────────────────────────────────\n\n'
    printf 'Required:\n'
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then printf '  ✓ %s\n' "$tool"
        else printf '  ✗ %s\n' "$tool"; missing=1; fi
    done
    printf '\nOptional (needed only for selected modules):\n'
    for tool in "${OPTIONAL_TOOLS[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then printf '  ✓ %s\n' "$tool"
        else printf '  - %s\n' "$tool"; fi
    done
    printf '\n'
    if ((missing)); then print_error "Missing required dependencies."; return 1; fi
    print_success "Required dependencies are available."
}
