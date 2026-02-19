#!/bin/bash

# ==========================================
#  AutomationTools - Subdomain Module
#  Author: Bhavya Sehgal
#  Description: Structured subdomain enumeration
#  Use: Authorized lab environments only
# ==========================================

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ==========================================
# Help Menu
# ==========================================

show_help() {
    echo ""
    echo "=============================================="
    echo " AutomationTools - Subdomain Enumeration"
    echo "=============================================="
    echo ""
    echo "Usage:"
    echo "  $0 -d <domain> [options]"
    echo ""
    echo "Options:"
    echo "  -d <domain>     Specify target domain"
    echo "  -l              Auto check live subdomains"
    echo "  -h, --help      Show this help menu"
    echo ""
    echo "Description:"
    echo "  This tool performs structured subdomain"
    echo "  enumeration using multiple engines:"
    echo "    • Subfinder"
    echo "    • Assetfinder"
    echo "    • Findomain"
    echo "    • Amass (if RAM >= 3GB)"
    echo ""
    echo "  Results are cleaned, deduplicated,"
    echo "  and optionally saved to:"
    echo "    /home/kali/automationtools/subdomains/"
    echo ""
    echo "Examples:"
    echo "  $0 -d example.com"
    echo "  $0 -d example.com -l"
    echo ""
    echo "Use only in authorized lab environments."
    echo "=============================================="
    echo ""
    exit 0
}

# ==========================================
# Tool Checker
# ==========================================

check_tool() {
    command -v "$1" &> /dev/null
}

# ==========================================
# Parse Arguments
# ==========================================

domain=""
auto_live=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d)
            domain="$2"
            shift 2
            ;;
        -l)
            auto_live=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}[!] Unknown option: $1${NC}"
            echo "Use -h or --help for usage."
            exit 1
            ;;
    esac
done

# Ask if domain missing
if [ -z "$domain" ]; then
    read -p "Enter Target Domain: " domain
fi

safe_domain=$(echo "$domain" | tr -cd '[:alnum:]._-')

if [ -z "$safe_domain" ]; then
    echo -e "${RED}[!] Invalid domain.${NC}"
    exit 1
fi

# ==========================================
# Directory Structure
# ==========================================

BASE_DIR="/home/kali/automationtools"
SUB_DIR="$BASE_DIR/subdomains"
mkdir -p "$SUB_DIR"

timestamp=$(date +"%Y%m%d_%H%M%S")
date_now=$(date +"%Y-%m-%d %H:%M:%S")

ip=$(dig +short "$safe_domain" | head -n 1 || true)

# ==========================================
# Display Target Info
# ==========================================

echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN} Target Information${NC}"
echo -e "${CYAN}=========================================${NC}"
echo -e "${YELLOW}Domain:${NC} $safe_domain"
echo -e "${YELLOW}IP:${NC} ${ip:-Not Resolved}"
echo -e "${YELLOW}Date:${NC} $date_now"
echo ""

# ==========================================
# Run Enumeration (Live Output Enabled)
# ==========================================

temp_file=$(mktemp)

echo -e "${CYAN}[+] Running Subfinder...${NC}"
if check_tool subfinder; then
    subfinder -d "$safe_domain" -silent | tee -a "$temp_file"
else
    echo -e "${YELLOW}[!] Subfinder not installed. Skipping.${NC}"
fi

echo -e "${CYAN}[+] Running Assetfinder...${NC}"
if check_tool assetfinder; then
    assetfinder --subs-only "$safe_domain" | tee -a "$temp_file"
else
    echo -e "${YELLOW}[!] Assetfinder not installed. Skipping.${NC}"
fi

echo -e "${CYAN}[+] Running Findomain...${NC}"
if check_tool findomain; then
    findomain -t "$safe_domain" -q | tee -a "$temp_file"
else
    echo -e "${YELLOW}[!] Findomain not installed. Skipping.${NC}"
fi

available_ram=$(free -m | awk '/Mem:/ {print $2}')
if [ "$available_ram" -ge 3000 ] && check_tool amass; then
    echo -e "${CYAN}[+] Running Amass (Passive)...${NC}"
    amass enum -passive -d "$safe_domain" | tee -a "$temp_file"
else
    echo -e "${YELLOW}[!] Skipping Amass (low RAM or not installed).${NC}"
fi

# ==========================================
# Clean Results
# ==========================================

clean_file=$(mktemp)

grep -i "\.$safe_domain$" "$temp_file" | \
sed 's/^https\?:\/\///' | \
sed 's/[^a-zA-Z0-9.-]//g' | \
grep -E "^[a-zA-Z0-9.-]+\.$safe_domain$" | \
grep -v "\.\." | \
sort -u > "$clean_file"

rm "$temp_file"

total=$(wc -l < "$clean_file")

if [ "$total" -eq 0 ]; then
    rm -f "$clean_file"
    echo -e "${RED}[!] No subdomains found.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}[✓] Total Unique Subdomains Found: $total${NC}"
echo ""

# ==========================================
# Ask Before Saving
# ==========================================

read -p "Do you want to save the results? (y/n): " save_choice

if [[ "$save_choice" =~ ^[Yy]$ ]]; then

    output_file="$SUB_DIR/${safe_domain}_subdomains_$timestamp.txt"

    {
        echo "========================================="
        echo "Scan Date: $date_now"
        echo "Domain: $safe_domain"
        echo "IP: ${ip:-Not Resolved}"
        echo "========================================="
        echo ""
        cat "$clean_file"
    } > "$output_file"

    echo -e "${GREEN}[✓] Saved to: $output_file${NC}"

else
    echo -e "${YELLOW}[!] Results discarded.${NC}"
fi

rm -f "$clean_file"

echo ""
echo -e "${GREEN}[✓] Subdomain Recon Completed Successfully.${NC}"
echo ""

# ==========================================
# Ask to Check Live Subdomains
# ==========================================

if $auto_live; then
    live_choice="y"
else
    read -p "Check live subdomains? (y/n): " live_choice
fi

if [[ "$live_choice" =~ ^[Yy]$ ]]; then

    if ! check_tool httpx; then
        echo -e "${RED}[!] httpx is not installed. Install it to check live hosts.${NC}"
        exit 1
    fi

    echo ""
    echo -e "${CYAN}[+] Checking Live Subdomains...${NC}"
    echo ""

    live_temp=$(mktemp)

    # Use cleaned file if not saved
    if [ -f "$clean_file" ]; then
        input_file="$clean_file"
    else
        input_file="$output_file"
    fi

    httpx -silent -l "$input_file" | tee -a "$live_temp"

    live_total=$(wc -l < "$live_temp")

    echo ""
    echo -e "${GREEN}[✓] Live Subdomains Found: $live_total${NC}"
    echo ""

    if [ "$live_total" -gt 0 ]; then
        read -p "Do you want to save live results? (y/n): " save_live

        if [[ "$save_live" =~ ^[Yy]$ ]]; then
            live_file="$SUB_DIR/${safe_domain}_live_$timestamp.txt"
            mv "$live_temp" "$live_file"
            echo -e "${GREEN}[✓] Live results saved to: $live_file${NC}"
        else
            rm -f "$live_temp"
            echo -e "${YELLOW}[!] Live results discarded.${NC}"
        fi
    else
        rm -f "$live_temp"
        echo -e "${RED}[!] No live subdomains found.${NC}"
    fi
fi
