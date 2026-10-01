#!/usr/bin/env bash

if [[ "${AUTOMATIONTOOLS_VALIDATION_LOADED:-false}" == true ]]; then
    return
fi

AUTOMATIONTOOLS_VALIDATION_LOADED=true

validate_domain() {

    local domain="$1"

    if [[ "$domain" =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    fi

    return 1
}

validate_ip() {

    local ip="$1"

    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

        IFS='.' read -r a b c d <<< "$ip"

        for octet in "$a" "$b" "$c" "$d"; do
            if (( octet > 255 )); then
                return 1
            fi
        done

        return 0
    fi

    return 1
}

validate_target() {

    local target="$1"

    if validate_domain "$target"; then
        debug "Target validated as domain: $target"
        return 0
    fi

    if validate_ip "$target"; then
        debug "Target validated as IPv4 address: $target"
        return 0
    fi

    die "Invalid target: $target"
}

validate_url() {

    local url="$1"

    if [[ "$url" =~ ^https?://[^[:space:]]+$ ]]; then
        debug "URL validated: $url"
        return 0
    fi

    die "Invalid URL: $url"
}

validate_wordlist() {

    local wordlist="$1"

    if [[ ! -f "$wordlist" ]]; then
        die "Wordlist does not exist: $wordlist"
    fi

    if [[ ! -r "$wordlist" ]]; then
        die "Wordlist is not readable: $wordlist"
    fi

    debug "Wordlist validated: $wordlist"
}
