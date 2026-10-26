#!/usr/bin/env bash
set -Eeuo pipefail

run_subdomain_scan() {
    local target="$1"
    local raw_file final_file target_name ran=0 failures=0
    target_name="$(safe_filename "$target")"
    raw_file="$OUTPUT_DIR/.${target_name}_subdomain_raw_$$.txt"
    final_file="$OUTPUT_DIR/${target_name}_subdomain.txt"
    : > "$raw_file"
    print_info "Starting passive subdomain enumeration for $target"
    if command -v subfinder >/dev/null 2>&1; then
        ran=1; print_info "Running Subfinder"
        subfinder -d "$target" -silent >> "$raw_file" || { print_warning "Subfinder failed."; failures=$((failures+1)); }
    fi
    if command -v assetfinder >/dev/null 2>&1; then
        ran=1; print_info "Running Assetfinder"
        assetfinder --subs-only "$target" >> "$raw_file" || { print_warning "Assetfinder failed."; failures=$((failures+1)); }
    fi
    if command -v findomain >/dev/null 2>&1; then
        ran=1; print_info "Running Findomain"
        findomain -t "$target" -q >> "$raw_file" || { print_warning "Findomain failed."; failures=$((failures+1)); }
    fi
    if ((ran == 0)); then
        rm -f -- "$raw_file"
        print_error "No supported subdomain enumeration tool found. Install Subfinder, Assetfinder, or Findomain."
        return 1
    fi
    if [[ -s "$raw_file" ]]; then
        sort -fu "$raw_file" > "$final_file"
        local count
        count="$(wc -l < "$final_file" | tr -d ' ')"
        print_success "Unique subdomains: $count"
        print_success "Results: $final_file"
    else
        : > "$final_file"
        print_warning "Enumeration completed with no results."
    fi
    rm -f -- "$raw_file"
    if ((failures > 0)); then
        print_warning "$failures enumeration tool(s) failed; results may be incomplete."
        return 1
    fi
    return 0
}
