#!/usr/bin/env bash

set -Eeuo pipefail

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/dependencies.sh"
source "$SCRIPT_DIR/lib/validation.sh"

# Modules
source "$SCRIPT_DIR/modules/nmap.sh"
source "$SCRIPT_DIR/modules/subdomains.sh"
source "$SCRIPT_DIR/modules/directory.sh"

TARGET=""
URL=""
MODE=""
NMAP_MODE="service"
WORDLIST=""
VERBOSE=false

usage() {
    cat <<EOF

AutomationTools v$VERSION
Reconnaissance Automation Suite

Usage:
    ./automationtools.sh [options]

Options:
    -t, --target <target>       Target domain/IP
    -u, --url <url>             Target URL for directory discovery
    -m, --module <module>       Module to run
                                nmap
                                subdomains
                                directory
                                full

    --nmap-mode <mode>          Nmap scan mode:
                                quick
                                service
                                full

    -w, --wordlist <file>       Wordlist for directory discovery
    -v, --verbose               Enable verbose output
    -c, --check                 Check dependencies
    -h, --help                  Show this help
    --version                   Show version

Examples:

    ./automationtools.sh -t example.com -m nmap

    ./automationtools.sh -t example.com \
        -m nmap \
        --nmap-mode quick

    ./automationtools.sh -t example.com \
        -m subdomains

    ./automationtools.sh \
        -u https://example.com \
        -m directory

    ./automationtools.sh \
        -t example.com \
        -u https://example.com \
        -m full

EOF
}

version() {
    echo "AutomationTools v$VERSION"
}

parse_args() {

    while [[ $# -gt 0 ]]; do

        case "$1" in

            -t|--target)
                [[ $# -ge 2 ]] || die "Missing value for $1"
                TARGET="$2"
                shift 2
                ;;

            -u|--url)
                [[ $# -ge 2 ]] || die "Missing value for $1"
                URL="$2"
                shift 2
                ;;

            -m|--module)
                [[ $# -ge 2 ]] || die "Missing value for $1"
                MODE="$2"
                shift 2
                ;;

            --nmap-mode)
                [[ $# -ge 2 ]] || die "Missing value for $1"
                NMAP_MODE="$2"
                shift 2
                ;;

            -w|--wordlist)
                [[ $# -ge 2 ]] || die "Missing value for $1"
                WORDLIST="$2"
                shift 2
                ;;

            -v|--verbose)
                VERBOSE=true
                shift
                ;;

            -c|--check)
                check_all_dependencies
                exit 0
                ;;

            -h|--help)
                usage
                exit 0
                ;;

            --version)
                version
                exit 0
                ;;

            *)
                die "Unknown option: $1. Use --help for usage."
                ;;

        esac

    done
}

validate_options() {

    case "$MODE" in
        nmap|subdomains|directory|full)
            ;;
        "")
            die "No module selected. Use -m nmap|subdomains|directory|full"
            ;;
        *)
            die "Invalid module: $MODE"
            ;;
    esac

    case "$NMAP_MODE" in
        quick|service|full)
            ;;
        *)
            die "Invalid Nmap mode: $NMAP_MODE"
            ;;
    esac

    if [[ "$MODE" == "nmap" || "$MODE" == "subdomains" || "$MODE" == "full" ]]; then
        [[ -n "$TARGET" ]] || die "This module requires --target"
        validate_target "$TARGET"
    fi

    if [[ "$MODE" == "directory" ]]; then
        [[ -n "$URL" ]] || die "Directory module requires --url"
        validate_url "$URL"
    fi

    if [[ "$MODE" == "full" ]]; then

        if [[ -n "$URL" ]]; then
            validate_url "$URL"
        else
            warning "No URL supplied. Directory discovery will be skipped."
        fi

    fi

    if [[ -n "$WORDLIST" ]]; then
        validate_wordlist "$WORDLIST"
    fi
}

prepare_environment() {

    local target_name="automation"

    if [[ -n "$TARGET" ]]; then
        target_name="$(sanitize_filename "$TARGET")"
    elif [[ -n "$URL" ]]; then
        target_name="$(sanitize_filename "$URL")"
    fi

    init_results "$target_name"

    info "Results directory: $RUN_DIR"
}

run_module() {

    case "$MODE" in

        nmap)
            check_nmap_dependencies
            run_nmap "$TARGET" "$NMAP_MODE"
            ;;

        subdomains)
            check_subdomain_dependencies
            run_subdomains "$TARGET"
            ;;

        directory)
            check_directory_dependencies
            run_directory "$URL" "$WORDLIST"
            ;;

        full)

            check_nmap_dependencies
            check_subdomain_dependencies

            info "Starting full reconnaissance..."

            run_nmap "$TARGET" "$NMAP_MODE"
            run_subdomains "$TARGET"

            if [[ -n "$URL" ]]; then
                check_directory_dependencies
                run_directory "$URL" "$WORDLIST"
            else
                warning "Directory discovery skipped because no URL was supplied."
            fi

            success "Full reconnaissance completed."
            ;;

    esac
}

main() {

    print_banner

    parse_args "$@"
    validate_options
    prepare_environment

    if [[ "$VERBOSE" == true ]]; then
        info "Verbose mode enabled."
    fi

    run_module

    success "AutomationTools finished."
    info "Results saved in: $RUN_DIR"
}

main "$@"
