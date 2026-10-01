#!/usr/bin/env bash

run_subdomains() {

    local target="$1"

    local output_dir="$RUN_DIR/subdomains"
    local combined="$output_dir/all_subdomains.txt"

    mkdir -p "$output_dir"

    info "Starting subdomain enumeration for $target..."

    : > "$combined"

    if command_exists subfinder; then

        info "Running Subfinder..."

        subfinder \
            -d "$target" \
            -silent \
            -o "$output_dir/subfinder.txt" || {
                warning "Subfinder encountered an error."
            }

        cat "$output_dir/subfinder.txt" >> "$combined" 2>/dev/null || true
    fi

    if command_exists assetfinder; then

        info "Running Assetfinder..."

        assetfinder \
            --subs-only "$target" \
            > "$output_dir/assetfinder.txt" || {
                warning "Assetfinder encountered an error."
            }

        cat "$output_dir/assetfinder.txt" >> "$combined" 2>/dev/null || true
    fi

    if command_exists findomain; then

        info "Running Findomain..."

        findomain \
            -t "$target" \
            -q \
            -u "$output_dir/findomain.txt" || {
                warning "Findomain encountered an error."
            }

        cat "$output_dir/findomain.txt" >> "$combined" 2>/dev/null || true
    fi

    if command_exists amass; then

        info "Running Amass passive enumeration..."

        amass enum \
            -passive \
            -d "$target" \
            -o "$output_dir/amass.txt" || {
                warning "Amass encountered an error."
            }

        cat "$output_dir/amass.txt" >> "$combined" 2>/dev/null || true
    fi

    if [[ -s "$combined" ]]; then

        sort -u "$combined" > "$output_dir/subdomains_unique.txt"

        rm -f "$combined"

        local count

        count="$(wc -l < "$output_dir/subdomains_unique.txt" | tr -d ' ')"

        success "Subdomain enumeration completed."
        info "Unique subdomains found: $count"
        info "Output: $output_dir/subdomains_unique.txt"

        # Optional live-host detection
        if command_exists httpx; then

            info "httpx found. Checking live HTTP services..."

            httpx \
                -silent \
                -l "$output_dir/subdomains_unique.txt" \
                -o "$output_dir/live_hosts.txt" || {
                    warning "httpx encountered an error."
                }

            if [[ -f "$output_dir/live_hosts.txt" ]]; then
                success "Live host results saved."
            fi
        fi

    else

        warning "No subdomains were discovered."

        rm -f "$combined"
    fi
}
