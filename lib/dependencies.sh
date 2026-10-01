#!/usr/bin/env bash

if [[ "${AUTOMATIONTOOLS_DEPENDENCIES_LOADED:-false}" == true ]]; then
    return
fi

AUTOMATIONTOOLS_DEPENDENCIES_LOADED=true

check_dependency() {

    local command_name="$1"

    if command_exists "$command_name"; then
        success "$command_name found."
        return 0
    fi

    warning "$command_name is not installed."
    return 1
}

require_dependency() {

    local command_name="$1"

    if ! command_exists "$command_name"; then
        die "$command_name is required but was not found."
    fi
}

check_nmap_dependencies() {

    info "Checking Nmap dependencies..."

    require_dependency nmap

    success "Nmap dependency check passed."
}

check_subdomain_dependencies() {

    info "Checking subdomain enumeration tools..."

    local found=0

    for tool in subfinder assetfinder amass findomain; do

        if command_exists "$tool"; then
            success "$tool found."
            found=1
        else
            warning "$tool not found."
        fi

    done

    if [[ "$found" -eq 0 ]]; then
        die "No supported subdomain enumeration tool was found."
    fi
}

check_directory_dependencies() {

    info "Checking directory discovery tools..."

    if command_exists gobuster; then
        success "Gobuster found."
        return 0
    fi

    if command_exists dirsearch; then
        success "Dirsearch found."
        return 0
    fi

    die "Neither Gobuster nor Dirsearch was found."
}

check_all_dependencies() {

    echo
    echo "Dependency Check"
    echo "================"
    echo

    echo "Core:"
    check_dependency bash
    check_dependency nmap

    echo
    echo "Subdomain Enumeration:"

    for tool in subfinder assetfinder amass findomain; do
        check_dependency "$tool" || true
    done

    echo
    echo "Directory Discovery:"

    check_dependency gobuster || true
    check_dependency dirsearch || true

    echo
    echo "Optional:"
    check_dependency httpx || true

    echo
    success "Dependency check completed."
}
