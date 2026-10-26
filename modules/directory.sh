#!/usr/bin/env bash
set -Eeuo pipefail

run_directory_scan() {
    local target="$1" wordlist="${2:-}"
    [[ -n "$target" ]] || { print_error "A web URL is required."; return 2; }
    local output_file target_name
    target_name="${target#*://}"
    target_name="${target_name%%/*}"
    target_name="${target_name%%:*}"
    target_name="$(safe_filename "$target_name")"
    output_file="$OUTPUT_DIR/${target_name}_directory.txt"
    if [[ -z "$wordlist" ]]; then
        if [[ -r /usr/share/wordlists/dirb/common.txt ]]; then
            wordlist=/usr/share/wordlists/dirb/common.txt
        elif [[ -r /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt ]]; then
            wordlist=/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt
        else
            print_error "No default wordlist found. Supply --wordlist <file>."
            return 1
        fi
    fi
    [[ -f "$wordlist" && -r "$wordlist" && -s "$wordlist" ]] || { print_error "Wordlist must exist, be readable, and be non-empty: $wordlist"; return 1; }
    if command -v gobuster >/dev/null 2>&1; then
        print_info "Running Gobuster against $target"
        if gobuster dir -u "$target" -w "$wordlist" -o "$output_file"; then
            :
        else
            local status=$?
            print_error "Gobuster failed (exit $status)."
            return "$status"
        fi
    elif command -v dirsearch >/dev/null 2>&1; then
        print_info "Running Dirsearch against $target"
        if dirsearch -u "$target" -w "$wordlist" --output="$output_file"; then
            :
        else
            local status=$?
            print_error "Dirsearch failed (exit $status)."
            return "$status"
        fi
    else
        print_error "Neither Gobuster nor Dirsearch is installed."
        return 1
    fi
    print_success "Directory discovery completed. Results: $output_file"
}
