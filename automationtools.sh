#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/dependencies.sh"
source "$SCRIPT_DIR/lib/validation.sh"

VERSION="2.0.0"

TARGET=""
MODULE=""
OUTPUT_DIR=""
WORDLIST=""
INTERACTIVE=false

show_banner() {
    echo
    echo "╔══════════════════════════════════════════════╗"
    echo "║              AutomationTools                ║"
    echo "║       Reconnaissance Automation Suite       ║"
    echo "║                  v$VERSION                    ║"
    echo "╚══════════════════════════════════════════════╝"
    echo
}

show_help() {
    cat << EOF

Usage:
  ./automationtools.sh [OPTIONS]

Options:
  -t, --target <target>       Target domain or IP
  -m, --module <module>       nmap|subdomains|directory|full
  -o, --output <directory>    Output directory
  -w, --wordlist <file>       Directory wordlist
      --check                 Check dependencies
      --interactive            Launch interactive menu
      --version               Show version
  -h, --help                  Show this help

Examples:

  ./automationtools.sh -t example.com -m nmap

  ./automationtools.sh -t example.com -m subdomains

  ./automationtools.sh -t example.com -m directory

  ./automationtools.sh -t example.com -m full

  ./automationtools.sh --interactive

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--target)
                [[ $# -ge 2 ]] || die "Missing value for --target"
                TARGET="$2"
                shift 2
                ;;

            -m|--module)
                [[ $# -ge 2 ]] || die "Missing value for --module"
                MODULE="$2"
                shift 2
                ;;

            -o|--output)
                [[ $# -ge 2 ]] || die "Missing value for --output"
                OUTPUT_DIR="$2"
                shift 2
                ;;

            -w|--wordlist)
                [[ $# -ge 2 ]] || die "Missing value for --wordlist"
                WORDLIST="$2"
                shift 2
                ;;

            --check)
                check_dependencies
                exit 0
                ;;

            --interactive)
                INTERACTIVE=true
                shift
                ;;

            --version)
                echo "AutomationTools v$VERSION"
                exit 0
                ;;

            -h|--help)
                show_help
                exit 0
                ;;

            *)
                die "Unknown option: $1. Use --help for usage."
                ;;
        esac
    done
}

setup_output() {
    if [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR="$SCRIPT_DIR/results"
    fi

    mkdir -p "$OUTPUT_DIR"

    export OUTPUT_DIR
}

run_nmap() {
    source "$SCRIPT_DIR/modules/nmap.sh"

    run_nmap_scan "$TARGET"
}

run_subdomains() {
    source "$SCRIPT_DIR/modules/subdomains.sh"

    run_subdomain_scan "$TARGET"
}

run_directory() {
    source "$SCRIPT_DIR/modules/directory.sh"

    run_directory_scan "$TARGET" "$WORDLIST"
}

run_full_scan() {
    print_info "Starting full reconnaissance workflow."

    run_nmap
    run_subdomains
    run_directory

    print_success "Full reconnaissance completed."
    print_info "Results saved in: $OUTPUT_DIR"
}

interactive_menu() {

    while true; do

        clear
        show_banner

        echo "[1] Network Scan"
        echo "[2] Subdomain Enumeration"
        echo "[3] Directory Discovery"
        echo "[4] Full Recon"
        echo "[5] Dependency Check"
        echo "[6] Help"
        echo "[0] Exit"
        echo

        read -rp "Select an option: " choice

        case "$choice" in

            1)
                read -rp "Target: " TARGET
                validate_target "$TARGET"
                setup_output
                run_nmap
                ;;

            2)
                read -rp "Target domain: " TARGET
                validate_domain "$TARGET"
                setup_output
                run_subdomains
                ;;

            3)
                read -rp "Target: " TARGET
                read -rp "Wordlist [optional]: " WORDLIST

                validate_target "$TARGET"
                setup_output

                run_directory
                ;;

            4)
                read -rp "Target: " TARGET
                validate_target "$TARGET"

                setup_output
                run_full_scan
                ;;

            5)
                check_dependencies
                ;;

            6)
                show_help
                ;;

            0)
                print_info "Exiting AutomationTools."
                exit 0
                ;;

            *)
                print_error "Invalid option."
                ;;
        esac

        echo
        read -rp "Press Enter to continue..."
    done
}

main() {

    show_banner

    parse_arguments "$@"

    if [[ "$INTERACTIVE" == true ]]; then
        interactive_menu
        exit 0
    fi

    if [[ -z "$TARGET" ]]; then
        show_help
        exit 1
    fi

    validate_target "$TARGET"
    setup_output

    case "${MODULE:-}" in

        nmap)
            run_nmap
            ;;

        subdomains)
            validate_domain "$TARGET"
            run_subdomains
            ;;

        directory)
            run_directory
            ;;

        full)
            run_full_scan
            ;;

        "")
            die "No module specified. Use -m or --interactive."

            ;;

        *)
            die "Invalid module: $MODULE"
            ;;
    esac
}

main "$@"
