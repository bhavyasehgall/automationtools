#!/usr/bin/env bash

set -Eeuo pipefail

run_subdomain_scan() {

    local target="$1"

    local scan_dir="$OUTPUT_DIR/subdomains"

    mkdir -p "$scan_dir"

    local timestamp
    timestamp="$(get_timestamp)"

    local raw_file="$scan_dir/raw_${timestamp}.txt"
    local final_file="$scan_dir/subdomains_${timestamp}.txt"

    : > "$raw_file"

    print_info "Starting subdomain enumeration: $target"

    if command -v subfinder >/dev/null 2>&1; then

        print_info "Running Subfinder..."

        subfinder \
            -d "$target" \
            -silent >> "$raw_file" || true

    else
        print_warning "Subfinder not installed."
    fi

    if command -v assetfinder >/dev/null 2>&1; then

        print_info "Running Assetfinder..."

        assetfinder \
            --subs-only "$target" >> "$raw_file" || true

    else
        print_warning "Assetfinder not installed."
    fi

    if command -v findomain >/dev/null 2>&1; then

        print_info "Running Findomain..."

        findomain \
            -t "$target" \
            -q >> "$raw_file" || true

    else
        print_warning "Findomain not installed."
    fi

    if [[ ! -s "$raw_file" ]]; then
        print_warning "No subdomains were discovered."
        rm -f "$raw_file"
        return 0
    fi

    sort -u "$raw_file" > "$final_file"

    rm -f "$raw_file"

    local count
    count="$(wc -l < "$final_file")"

    print_success "Subdomain enumeration completed."
    print_success "Unique subdomains: $count"
    print_success "Results: $final_file"
}
