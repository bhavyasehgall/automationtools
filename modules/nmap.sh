#!/usr/bin/env bash

set -Eeuo pipefail

run_nmap_scan() {

    local target="$1"

    if ! command -v nmap >/dev/null 2>&1; then
        print_error "Nmap is not installed."
        return 1
    fi

    local scan_dir="$OUTPUT_DIR/nmap"

    mkdir -p "$scan_dir"

    local timestamp
    timestamp="$(get_timestamp)"

    local output_file="$scan_dir/nmap_${timestamp}.txt"

    print_info "Starting Nmap scan against: $target"

    echo "AutomationTools - Nmap Scan" > "$output_file"
    echo "Target: $target" >> "$output_file"
    echo "Timestamp: $timestamp" >> "$output_file"
    echo "----------------------------------------" >> "$output_file"

    if nmap -sV "$target" | tee -a "$output_file"; then

        print_success "Nmap scan completed."
        print_success "Results: $output_file"

        return 0

    else

        print_error "Nmap scan failed."
        return 1

    fi
}
