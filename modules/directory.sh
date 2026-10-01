#!/usr/bin/env bash

find_default_wordlist() {

    local candidates=(
        "/usr/share/wordlists/dirb/common.txt"
        "/usr/share/seclists/Discovery/Web-Content/common.txt"
        "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    )

    for wordlist in "${candidates[@]}"; do

        if [[ -f "$wordlist" ]]; then
            echo "$wordlist"
            return 0
        fi

    done

    return 1
}

run_directory() {

    local url="$1"
    local custom_wordlist="${2:-}"

    local output_dir="$RUN_DIR/directory"

    mkdir -p "$output_dir"

    local wordlist=""

    if [[ -n "$custom_wordlist" ]]; then

        validate_wordlist "$custom_wordlist"

        wordlist="$custom_wordlist"

    else

        if wordlist="$(find_default_wordlist)"; then
            info "Using detected wordlist: $wordlist"
        else
            die "No suitable wordlist found. Use --wordlist."
        fi

    fi

    if command_exists gobuster; then

        local output="$output_dir/gobuster.txt"

        info "Running Gobuster against $url..."

        gobuster dir \
            -u "$url" \
            -w "$wordlist" \
            -o "$output" \
            -q || {
                warning "Gobuster encountered an error."
            }

        if [[ -f "$output" ]]; then
            success "Gobuster scan completed."
            info "Output: $output"
        fi

        return 0
    fi

    if command_exists dirsearch; then

        local output="$output_dir/dirsearch.txt"

        info "Running Dirsearch against $url..."

        dirsearch \
            -u "$url" \
            -w "$wordlist" \
            --plain-text-report="$output" || {
                warning "Dirsearch encountered an error."
            }

        if [[ -f "$output" ]]; then
            success "Dirsearch scan completed."
            info "Output: $output"
        fi

        return 0
    fi

    die "No directory discovery tool available."
}
