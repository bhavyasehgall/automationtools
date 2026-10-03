#!/usr/bin/env bash

set -Eeuo pipefail

validate_target() {

    local target="$1"

    if [[ -z "$target" ]]; then
        die "Target cannot be empty."
    fi

    if [[ "$target" =~ [[:space:]] ]]; then
        die "Target cannot contain spaces."
    fi

    if [[ "$target" =~ ^https?:// ]]; then
        target="${target#http://}"
        target="${target#https://}"
        target="${target%%/*}"
    fi

    print_success "Target accepted: $target"
}

validate_domain() {

    local domain="$1"

    if [[ -z "$domain" ]]; then
        die "Domain cannot be empty."
    fi

    if [[ "$domain" =~ ^https?:// ]]; then
        die "For domain enumeration provide the domain without http:// or https://"
    fi

    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        die "Invalid domain format."
    fi

    print_success "Domain accepted: $domain"
}
