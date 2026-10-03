#!/usr/bin/env bash

set -Eeuo pipefail

run_directory_scan() {

    local target="$1"
    local wordlist="${2:-}"

    local scan_dir="$OUTPUT_DIR/directories"

    mkdir -p "$scan_dir"

    local timestamp
    timestamp="$(get_timestamp)"

    local output_file="$scan_dir/directories_${timestamp}.txt"

    if [[ -z "$wordlist" ]]; then

        if [[ -f "/usr/share/wordlists/dirb/common.txt" ]]; then
            wordlist="/usr/share/wordlists/dirb/common.txt"

        elif [[ -f "/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt" ]]; then
            wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"

        else
            print_warning "No default wordlist found."
            print_info "Use --wordlist <file>."
            return 1
        fi

    fi

    if [[ ! -f "$wordlist" ]]; then
        print_error "Wordlist not found: $wordlist"
        return 1
    fi

    if command -v gobuster >/dev/null 2>&1; then

        print_info "Running Gobuster..."

        gobuster dir \
            -u "$target" \
            -w "$wordlist" \
            -o "$output_file"

        print_success "Directory discovery completed."
        print_success "Results: $output_file"

        return 0

    fi

    if command -v dirsearch >/dev/null 2>&1; then

        print_info "Running Dirsearch..."

        dirsearch \
            -u "$target" \
            -w "$wordlist" \
            --output="$output_file"

        print_success "Directory discovery completed."
        print_success "Results: $output_file"

        return 0

    fi

    print_error "Neither Gobuster nor Dirsearch is installed."

    return 1
}
