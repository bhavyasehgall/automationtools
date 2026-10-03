#!/usr/bin/env bash

set -Eeuo pipefail

REQUIRED_TOOLS=(
    "bash"
    "nmap"
)

OPTIONAL_TOOLS=(
    "subfinder"
    "assetfinder"
    "findomain"
    "amass"
    "httpx"
    "gobuster"
    "dirsearch"
)

check_dependencies() {

    echo
    echo "Dependency Check"
    echo "────────────────────────────────"
    echo

    local missing_required=0

    echo "Required:"
    echo

    for tool in "${REQUIRED_TOOLS[@]}"; do

        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✓ $tool"
        else
            echo "  ✗ $tool"
            missing_required=1
        fi

    done

    echo
    echo "Optional:"
    echo

    for tool in "${OPTIONAL_TOOLS[@]}"; do

        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✓ $tool"
        else
            echo "  - $tool"
        fi

    done

    echo

    if [[ "$missing_required" -eq 1 ]]; then
        echo "Status: MISSING REQUIRED DEPENDENCIES"
        return 1
    fi

    echo "Status: READY"
}
