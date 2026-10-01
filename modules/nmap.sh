#!/usr/bin/env bash

nmap_quick() {

    local target="$1"
    local output="$RUN_DIR/nmap_quick.txt"

    info "Running quick Nmap scan against $target..."

    nmap \
        --top-ports 100 \
        -T3 \
        "$target" \
        -oN "$output" || {
            error "Nmap quick scan failed."
            return 1
        }

    success "Quick Nmap scan completed."
    info "Output: $output"
}

nmap_service() {

    local target="$1"
    local output="$RUN_DIR/nmap_service.txt"

    info "Running service detection against $target..."

    nmap \
        -sV \
        --top-ports 100 \
        -T3 \
        "$target" \
        -oN "$output" || {
            error "Nmap service scan failed."
            return 1
        }

    success "Service detection completed."
    info "Output: $output"
}

nmap_full() {

    local target="$1"
    local output="$RUN_DIR/nmap_full.txt"

    info "Running full TCP port scan against $target..."
    warning "This scan may take considerably longer."

    nmap \
        -sV \
        -p- \
        -T3 \
        "$target" \
        -oN "$output" || {
            error "Full Nmap scan failed."
            return 1
        }

    success "Full Nmap scan completed."
    info "Output: $output"
}

run_nmap() {

    local target="$1"
    local mode="${2:-service}"

    save_metadata "$target"

    case "$mode" in

        quick)
            nmap_quick "$target"
            ;;

        service)
            nmap_service "$target"
            ;;

        full)
            nmap_full "$target"
            ;;

        *)
            die "Unknown Nmap mode: $mode"
            ;;

    esac
}
