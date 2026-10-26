#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/dependencies.sh
source "$SCRIPT_DIR/lib/dependencies.sh"
# shellcheck source=lib/validation.sh
source "$SCRIPT_DIR/lib/validation.sh"

VERSION="2.1.0"
TARGET=""
URL=""
MODULE=""
OUTPUT_DIR=""
WORDLIST=""
NMAP_MODE="service"
INTERACTIVE=false
RUN_DIR=""

show_banner() {
    printf '\n╔══════════════════════════════════════════════╗\n'
    printf '║              AutomationTools                ║\n'
    printf '║       Reconnaissance Automation Suite       ║\n'
    printf '║                  v%-26s║\n' "$VERSION"
    printf '╚══════════════════════════════════════════════╝\n\n'
}

show_help() {
    cat <<EOF
Usage:
  ./automationtools.sh -t <domain-or-IP> -m <module> [options]

Modules:
  nmap          Network/service scan
  subdomains    Passive subdomain enumeration (domain only)
  directory     Web directory discovery (requires --url)
  full          Nmap + subdomains, and directory discovery if --url is supplied

Options:
  -t, --target <domain|IP>    Domain or IPv4 target
      --url <http(s)://host>  Web URL for directory discovery
  -m, --module <module>       nmap|subdomains|directory|full
  -o, --output <directory>    Base output directory (default: ./results)
  -w, --wordlist <file>       Directory wordlist
      --nmap-mode <mode>      quick|service|full (default: service)
      --check                 Check installed dependencies
      --interactive           Launch interactive menu
      --version               Show version
  -h, --help                  Show this help

Examples:
  ./automationtools.sh -t 192.168.1.10 -m nmap --nmap-mode quick
  ./automationtools.sh -t example.com -m subdomains
  ./automationtools.sh -t example.com -m full --url https://example.com
  ./automationtools.sh -t 127.0.0.1 -m directory --url http://127.0.0.1:8000

Only scan systems you own or have explicit permission to test.
EOF
}

need_value() {
    [[ $# -ge 2 && -n "$2" ]] || die "Missing value for $1"
    [[ "$2" != -* ]] || die "Invalid value for $1: $2"
}

parse_arguments() {
    while (($#)); do
        case "$1" in
            -t|--target) need_value "$@"; TARGET="$2"; shift 2 ;;
            --url) need_value "$@"; URL="$2"; shift 2 ;;
            -m|--module) need_value "$@"; MODULE="$2"; shift 2 ;;
            -o|--output) need_value "$@"; OUTPUT_DIR="$2"; shift 2 ;;
            -w|--wordlist) need_value "$@"; WORDLIST="$2"; shift 2 ;;
            --nmap-mode) need_value "$@"; NMAP_MODE="$2"; shift 2 ;;
            --check) check_dependencies; exit $? ;;
            --interactive) INTERACTIVE=true; shift ;;
            --version) printf 'AutomationTools v%s\n' "$VERSION"; exit 0 ;;
            -h|--help) show_help; exit 0 ;;
            *) die "Unknown option: $1. Use --help for usage." ;;
        esac
    done
}

setup_output() {
    local base_output="${OUTPUT_DIR:-$SCRIPT_DIR/results}"
    mkdir -p -- "$base_output" || die "Cannot create output directory: $base_output"
    OUTPUT_DIR="$(cd -- "$base_output" && pwd)"
    export OUTPUT_DIR
    print_info "Results directory: $OUTPUT_DIR"
    print_warning "A report with the same target and scan type will be overwritten by the next run."
}

run_nmap() {
    # shellcheck source=modules/nmap.sh
    source "$SCRIPT_DIR/modules/nmap.sh"
    run_nmap_scan "$TARGET" "$NMAP_MODE"
}

run_subdomains() {
    # shellcheck source=modules/subdomains.sh
    source "$SCRIPT_DIR/modules/subdomains.sh"
    run_subdomain_scan "$TARGET"
}

run_directory() {
    # shellcheck source=modules/directory.sh
    source "$SCRIPT_DIR/modules/directory.sh"
    run_directory_scan "$URL" "$WORDLIST"
}

run_full_scan() {
    local failures=0
    print_info "Starting full workflow. Each module reports its own status."
    run_nmap || failures=$((failures + 1))
    if validate_domain_silent "$TARGET"; then
        run_subdomains || failures=$((failures + 1))
    else
        print_warning "Subdomain enumeration skipped: target is not a domain name."
    fi
    if [[ -n "$URL" ]]; then
        run_directory || failures=$((failures + 1))
    else
        print_warning "Directory discovery skipped: supply --url <http(s)://host> to enable it."
    fi
    if ((failures)); then
        print_error "Workflow finished with $failures module(s) reporting failure."
        return 1
    fi
    print_success "Workflow finished."
}

interactive_menu() {
    while true; do
        show_banner
        printf '[1] Network scan\n[2] Subdomain enumeration\n[3] Directory discovery\n[4] Full workflow\n[5] Dependency check\n[6] Help\n[0] Exit\n\n'
        read -rp "Select an option: " choice
        case "$choice" in
            1)
                read -rp "Domain or IPv4 target: " TARGET
                read -rp "Nmap mode [quick/service/full]: " NMAP_MODE
                validate_host "$TARGET"; validate_nmap_mode "$NMAP_MODE"
                MODULE=nmap; setup_output; run_nmap || true ;;
            2)
                read -rp "Domain: " TARGET
                validate_domain "$TARGET"
                MODULE=subdomains; setup_output; run_subdomains || true ;;
            3)
                read -rp "Web URL: " URL
                read -rp "Wordlist [optional]: " WORDLIST
                validate_url "$URL"
                MODULE=directory; setup_output; run_directory || true ;;
            4)
                read -rp "Domain or IPv4 target: " TARGET
                read -rp "Web URL for optional directory discovery [blank to skip]: " URL
                validate_host "$TARGET"
                [[ -z "$URL" ]] || validate_url "$URL"
                MODULE=full; setup_output; run_full_scan || true ;;
            5) check_dependencies || true ;;
            6) show_help ;;
            0) print_info "Exiting."; return 0 ;;
            *) print_error "Invalid option." ;;
        esac
        printf '\n'
        read -rp "Press Enter to continue..." _
    done
}

main() {
    parse_arguments "$@"
    if [[ "$INTERACTIVE" == true ]]; then interactive_menu; return; fi
    [[ -n "$MODULE" ]] || { show_help; die "No module specified."; }
    case "$MODULE" in
        nmap)
            validate_host "$TARGET"; validate_nmap_mode "$NMAP_MODE" ;;
        subdomains)
            validate_domain "$TARGET" ;;
        directory)
            [[ -n "$URL" ]] || die "Directory module requires --url <http(s)://host>."
            validate_url "$URL" ;;
        full)
            validate_host "$TARGET"
            [[ -z "$URL" ]] || validate_url "$URL" ;;
        *) die "Invalid module: $MODULE" ;;
    esac
    if [[ -n "$WORDLIST" ]]; then validate_wordlist "$WORDLIST"; fi
    setup_output
    case "$MODULE" in
        nmap) run_nmap ;;
        subdomains) run_subdomains ;;
        directory) run_directory ;;
        full) run_full_scan ;;
    esac
}
main "$@"
