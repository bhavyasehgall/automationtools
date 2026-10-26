#!/usr/bin/env bash
set -Eeuo pipefail

run_nmap_scan() {
    local target="$1" mode="${2:-service}"
    command -v nmap >/dev/null 2>&1 || { print_error "Nmap is not installed."; return 1; }
    local target_name output_file
    target_name="$(safe_filename "$target")"
    output_file="$OUTPUT_DIR/${target_name}_nmap.txt"
    local -a args
    case "$mode" in
        quick) args=(-T3 --top-ports 100) ;;
        service) args=(-sV -T3 --top-ports 1000) ;;
        full) args=(-sV -T3 -p-) ;;
        *) print_error "Unsupported Nmap mode: $mode"; return 2 ;;
    esac
    print_info "Running Nmap mode '$mode' against $target"
    {
        printf 'AutomationTools - Nmap Scan\nTarget: %s\nMode: %s\nTimestamp: %s\n\n' "$target" "$mode" "$(get_timestamp)"
    } > "$output_file"
    if nmap "${args[@]}" -oN - -- "$target" 2>&1 | tee -a "$output_file"; then
        print_success "Nmap scan completed. Results: $output_file"
    else
        local status=$?
        print_error "Nmap scan failed (exit $status). Partial output: $output_file"
        return "$status"
    fi
}
