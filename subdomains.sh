#!/bin/bash

# ==========================================
#  AutomationTools - Subdomain Module
#  Author: Bhavya Sehgal
#  Description: Structured subdomain enumeration
#  Use: Authorized lab environments only
# ==========================================

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
    echo "Subdomain Enumeration Automation Tool"
    echo "--------------------------------------"
    echo ""
    echo "Usage:"
    echo "  $0 [options]"
    echo ""
    echo "Options:"
    echo "  -d, --domain <domain>     Target domain"
    echo "  -l, --live                Auto check live subdomains"
    echo "  --subfinder               Run Subfinder only"
    echo "  --assetfinder             Run Assetfinder only"
    echo "  --amass                   Run Amass only"
    echo "  --findomain               Run Findomain only"
    echo "  --all                     Run all tools (default)"
    echo "  -h, --help                Show help"
    echo ""
    echo "Examples:"
    echo "  $0 -d example.com --subfinder"
    echo "  $0 -d example.com --amass -l"
    echo ""
    exit 0
}
# ==========================================
# Tool Checker
# ==========================================

check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[!] $1 is not installed.${NC}"
        exit 1
    fi
}

# ==========================================
# Parse Arguments
# ==========================================

domain=""
auto_live=false

while getopts ":d:lh" opt; do
  case ${opt} in
    d ) domain=$OPTARG ;;
    l ) auto_live=true ;;
    h ) show_help ;;
    \? ) echo -e "${RED}Invalid option: -$OPTARG${NC}" ; exit 1 ;;
  esac
done

# Ask if missing
if [ -z "$domain" ]; then
    read -p "Enter Target Domain (example.com): " domain
fi

safe_domain=$(echo "$domain" | tr -cd '[:alnum:]._-')

if [ -z "$safe_domain" ]; then
    echo -e "${RED}[!] Invalid domain.${NC}"
    exit 1
fi

# ==========================================
# Structured Directories
# ==========================================

base_dir="/home/kali/automationtools"
mkdir -p "$base_dir/subdomains"

timestamp=$(date +"%Y%m%d_%H%M%S")
date_now=$(date +"%Y-%m-%d %H:%M:%S")

output_file="$base_dir/subdomains/${safe_domain}_subdomains_$timestamp.txt"

# Resolve IP
ip=$(dig +short "$safe_domain" | head -n 1)

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
# Check Required Tools
# ==========================================

check_tool subfinder
check_tool assetfinder

# Amass only if enough RAM
available_ram=$(free -m | awk '/Mem:/ {print $2}')

# ==========================================
# Run Enumeration
# ==========================================

temp_file=$(mktemp)

echo -e "${CYAN}[+] Running Subfinder...${NC}"
subfinder -d "$safe_domain" -silent | tee -a "$temp_file"

echo -e "${CYAN}[+] Running Assetfinder...${NC}"
assetfinder --subs-only "$safe_domain" | tee -a "$temp_file"

if [ "$available_ram" -ge 3000 ]; then
    if command -v amass &> /dev/null; then
        echo -e "${CYAN}[+] Running Amass (Passive)...${NC}"
        amass enum -passive -d "$safe_domain" | tee -a "$temp_file"
    else
        echo -e "${YELLOW}[!] Amass not installed. Skipping.${NC}"
    fi
else
    echo -e "${YELLOW}[!] RAM <3GB. Skipping Amass for stability.${NC}"
fi

# ==========================================
# Clean Results
# ==========================================

echo ""
echo -e "${YELLOW}[+] Cleaning Results...${NC}"

grep -i "\.$safe_domain$" "$temp_file" | \
sed 's/^https\?:\/\///' | \
sed 's/[^a-zA-Z0-9.-]//g' | \
grep -E "^[a-zA-Z0-9.-]+\.$safe_domain$" | \
grep -v "\.\." | \
sort -u > "$output_file"

rm "$temp_file"

total=$(wc -l < "$output_file")

if [ "$total" -eq 0 ]; then
    rm -f "$output_file"
    echo -e "${RED}[!] No subdomains found.${NC}"
    exit 0
fi

echo -e "${GREEN}[✓] Total Unique Subdomains: $total${NC}"
echo -e "${CYAN}[✓] Saved to: $output_file${NC}"

# ==========================================
# Live Check
# ==========================================

if $auto_live; then
    live_choice="y"
else
    read -p "Check live subdomains? (y/n): " live_choice
fi

if [[ "$live_choice" =~ ^[Yy]$ ]]; then

    check_tool httpx

    echo -e "${CYAN}[+] Checking Live Hosts...${NC}"

    live_file="$base_dir/subdomains/${safe_domain}_live_$timestamp.txt"

    httpx -l "$output_file" \
          -silent \
          -threads 40 \
          -timeout 5 \
          -no-color > "$live_file"

    live_total=$(wc -l < "$live_file")

    if [ "$live_total" -gt 0 ]; then
        echo -e "${GREEN}[✓] Live Subdomains Found: $live_total${NC}"
        echo -e "${CYAN}[✓] Saved to: $live_file${NC}"
    else
        rm -f "$live_file"
        echo -e "${RED}[!] No live subdomains found.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}[✓] Subdomain Recon Completed Successfully.${NC}"
echo ""
