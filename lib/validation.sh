#!/usr/bin/env bash
set -Eeuo pipefail

validate_host() {
    local host="${1:-}"
    [[ -n "$host" ]] || die "Target cannot be empty."
    [[ "$host" != -* ]] || die "Target must not begin with '-'."
    [[ "$host" != *[[:space:]]* ]] || die "Target cannot contain whitespace."
    if validate_ipv4_silent "$host"; then
        print_success "Target accepted: $host"
    elif [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        die "Invalid IPv4 address: $host"
    elif validate_domain_silent "$host"; then
        print_success "Target accepted: $host"
    else
        die "Invalid target. Supply a valid IPv4 address or domain name."
    fi
}
validate_ipv4_silent() {
    local ip="$1" octet
    local -a parts
    [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
    IFS='.' read -r -a parts <<< "$ip"
    ((${#parts[@]} == 4)) || return 1
    for octet in "${parts[@]}"; do
        [[ "$octet" =~ ^[0-9]{1,3}$ ]] || return 1
        ((10#$octet <= 255)) || return 1
    done
    return 0
}
validate_domain_silent() {
    local domain="$1"
    [[ ${#domain} -le 253 ]] || return 1
    [[ "$domain" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || return 1
    [[ "$domain" != *..* ]] || return 1
    local label
    IFS='.' read -r -a labels <<< "$domain"
    for label in "${labels[@]}"; do
        [[ -n "$label" && ${#label} -le 63 ]] || return 1
        [[ "$label" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]] || return 1
    done
    return 0
}
validate_domain() {
    local domain="${1:-}"
    [[ "$domain" != *"://"* ]] || die "Provide a domain without http:// or https://."
    validate_domain_silent "$domain" || die "Invalid domain format: $domain"
    print_success "Domain accepted: $domain"
}
validate_url() {
    local url="${1:-}" host
    [[ "$url" =~ ^https?://[^/[:space:]]+(/[^[:space:]]*)?$ ]] || die "Invalid URL. Use http://host or https://host, optionally with a path."
    host="${url#http://}"; host="${host#https://}"; host="${host%%/*}"
    host="${host%%:*}"
    if ! validate_ipv4_silent "$host" && ! validate_domain_silent "$host" && [[ "$host" != "localhost" ]]; then
        die "URL must contain a valid domain, IPv4 address, or localhost."
    fi
    print_success "URL accepted: $url"
}
validate_wordlist() {
    local wordlist="$1"
    [[ -f "$wordlist" && -r "$wordlist" ]] || die "Wordlist does not exist or is not readable: $wordlist"
    [[ -s "$wordlist" ]] || die "Wordlist is empty: $wordlist"
}
validate_nmap_mode() {
    case "${1:-}" in quick|service|full) ;; *) die "Invalid Nmap mode '${1:-}'. Choose quick, service, or full." ;; esac
}
