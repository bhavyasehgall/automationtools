#!/bin/bash

# ==========================================
#   Subdomain Enumeration Automation
#   Optimized for Low RAM (2GB Safe)
# ==========================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ==========================================
# Check Available RAM
# ==========================================

available_ram=$(free -m | awk '/Mem:/ {print $2}')

# ==========================================
# Tool Installer
# ==========================================

install_tool() {
    tool=$1

    echo -e "${YELLOW}[!] $tool is not installed.${NC}"
    read -p "Install $tool now? (y/n): " choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        case $tool in
            subfinder)
                sudo apt install -y subfinder ;;
            assetfinder)
                go install github.com/tomnomnom/assetfinder@latest ;;
            amass)
                sudo apt install -y amass ;;
            findomain)
                sudo apt install -y findomain ;;
            httpx)
                sudo apt install -y httpx-toolkit ;;
        esac

        export PATH=$PATH:$(go env GOPATH 2>/dev/null)/bin
    else
        echo -e "${RED}[!] $tool is required.${NC}"
        exit 1
    fi
}

check_tool() {
    command -v $1 &> /dev/null || install_tool $1
}

# Required tools
check_tool subfinder
check_tool assetfinder
check_tool findomain

# ==========================================
# Target Input
# ==========================================

read -p "Enter Target Domain: " domain
safe_domain=$(echo "$domain" | tr -cd '[:alnum:]._-')

if [ -z "$safe_domain" ]; then
    echo -e "${RED}[!] Invalid domain.${NC}"
    exit 1
fi

OUTPUT_DIR="recon/$safe_domain"
mkdir -p "$OUTPUT_DIR"

echo ""
echo -e "${YELLOW}[+] Starting Subdomain Enumeration...${NC}"
echo ""

temp_file=$(mktemp)

# ==========================================
# Run Tools Sequentially
# ==========================================

echo -e "${CYAN}[1/4] Subfinder...${NC}"
subfinder -d "$domain" -silent | tee -a "$temp_file"

echo -e "${CYAN}[2/4] Assetfinder...${NC}"
assetfinder --subs-only "$domain" | tee -a "$temp_file"

# ==========================================
# Smart Amass Execution
# ==========================================

if [ "$available_ram" -ge 3000 ]; then
    echo -e "${CYAN}[3/4] Amass (Limited Passive Mode)...${NC}"
    amass enum -passive -d "$domain" -max-dns-queries 50 | tee -a "$temp_file"
else
    echo -e "${YELLOW}[!] RAM too low (<3GB). Skipping Amass to prevent crash.${NC}"
fi

echo -e "${CYAN}[4/4] Findomain...${NC}"
findomain -t "$domain" -q | tee -a "$temp_file"

# ==========================================
# Clean + Remove Duplicates
# ==========================================

echo ""
echo -e "${YELLOW}[+] Cleaning & Removing Duplicates...${NC}"

cat "$temp_file" | \
grep -E "^[a-zA-Z0-9.-]+\.$domain$" | \
sort -u > "$OUTPUT_DIR/subdomains.txt"

total=$(wc -l < "$OUTPUT_DIR/subdomains.txt")
rm "$temp_file"

echo -e "${GREEN}[✓] Total Clean Unique Subdomains: $total${NC}"
echo -e "${CYAN}[✓] Saved to: $OUTPUT_DIR/subdomains.txt${NC}"

# ==========================================
# Optional Live Check
# ==========================================

read -p "Check live subdomains? (y/n): " live_choice

if [[ "$live_choice" =~ ^[Yy]$ ]]; then

    check_tool httpx

    echo -e "${CYAN}[+] Checking Live Hosts...${NC}"

    temp_live=$(mktemp)

    httpx -l "$OUTPUT_DIR/subdomains.txt" \
          -silent \
          -threads 40 \
          -timeout 5 \
          -no-color > "$temp_live"

    live_total=$(wc -l < "$temp_live")

    if [ "$live_total" -gt 0 ]; then
        mv "$temp_live" "$OUTPUT_DIR/live_subdomains.txt"
        echo -e "${GREEN}[✓] Live Subdomains Found: $live_total${NC}"
        echo -e "${CYAN}[✓] Saved to: $OUTPUT_DIR/live_subdomains.txt${NC}"
    else
        rm "$temp_live"
        echo -e "${RED}[!] No live subdomains found. File not created.${NC}"
    fi
fi

