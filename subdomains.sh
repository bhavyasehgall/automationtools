#!/bin/bash

# ====================================
#   Subdomain Enumeration Automation 
# ====================================

# Colors
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
# Smart Tool Checker (Auto Install + Loop)
# ==========================================

check_tool() {

    tool_name="$1"

    while true; do

        if command -v "$tool_name" &> /dev/null; then
            return 0
        fi

        echo -e "${RED}[!] $tool_name is not installed.${NC}"
        read -p "Do you want to install $tool_name now? (y/n): " choice

        if [[ "$choice" =~ ^[Yy]$ ]]; then

            echo -e "${YELLOW}[+] Installing $tool_name...${NC}"

            case "$tool_name" in
                subfinder)
                    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                    ;;
                httpx)
                    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
                    ;;
                amass)
                    go install -v github.com/owasp-amass/amass/v4/...@master
                    ;;
                assetfinder)
                    go install -v github.com/tomnomnom/assetfinder@latest
                    ;;
                findomain)
                    apt install -y findomain
                    ;;
                *)
                    echo -e "${RED}[!] Unknown tool. Install manually.${NC}"
                    exit 1
                    ;;
            esac

            export PATH=$HOME/go/bin:$PATH

            if command -v "$tool_name" &> /dev/null; then
                echo -e "${GREEN}[✓] $tool_name installed successfully.${NC}"
                return 0
            else
                echo -e "${RED}[!] Installation failed. Trying again...${NC}"
            fi

        else
            echo -e "${RED}[!] $tool_name is required to continue.${NC}"
        fi

    done
}

# ==========================================
# HTTPX Self-Healing Fix
# ==========================================

fix_httpx() {

    if command -v httpx &> /dev/null; then
        HTTPX_PATH=$(which httpx)
        if dpkg -S "$HTTPX_PATH" 2>/dev/null | grep -q "python3-httpx"; then
            echo -e "${RED}[!] Wrong Python httpx detected. Removing...${NC}"
            apt remove -y python3-httpx
        fi
    fi

    check_tool httpx

    if httpx -version &>/dev/null; then
        echo -e "${GREEN}[✓] httpx ready.${NC}"
    else
        echo -e "${RED}[!] httpx installation failed.${NC}"
        exit 1
    fi
}

# ==========================================
# Default Settings
# ==========================================

domain=""
auto_live=false
run_subfinder=false
run_assetfinder=false
run_amass=false
run_findomain=false

# ==========================================
# Argument Parsing
# ==========================================

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--domain)
            domain="$2"
            shift 2
            ;;
        -l|--live)
            auto_live=true
            shift
            ;;
        --subfinder)
            run_subfinder=true
            shift
            ;;
        --assetfinder)
            run_assetfinder=true
            shift
            ;;
        --amass)
            run_amass=true
            shift
            ;;
        --findomain)
            run_findomain=true
            shift
            ;;
        --all)
            run_subfinder=true
            run_assetfinder=true
            run_amass=true
            run_findomain=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}[!] Unknown option: $1${NC}"
            show_help
            ;;
    esac
done

# If no tool selected → run all
if ! $run_subfinder && ! $run_assetfinder && ! $run_amass && ! $run_findomain; then
    run_subfinder=true
    run_assetfinder=true
    run_amass=true
    run_findomain=true
fi

# ==========================================
# Ask Domain If Missing
# ==========================================

if [ -z "$domain" ]; then
    read -p "Enter Target Domain: " domain
fi

safe_domain=$(echo "$domain" | tr -cd '[:alnum:]._-')

if [ -z "$safe_domain" ]; then
    echo -e "${RED}[!] Invalid domain.${NC}"
    exit 1
fi

# ==========================================
# Setup
# ==========================================

OUTPUT_DIR="recon/$safe_domain"
mkdir -p "$OUTPUT_DIR"
temp_file=$(mktemp)
available_ram=$(free -m | awk '/Mem:/ {print $2}')

echo ""
echo -e "${YELLOW}[+] Starting Enumeration...${NC}"
echo ""

# ==========================================
# Run Selected Tools
# ==========================================

if $run_subfinder; then
    check_tool subfinder
    echo -e "${CYAN}[+] Running Subfinder...${NC}"
    subfinder -d "$domain" -silent | tee -a "$temp_file"
fi

if $run_assetfinder; then
    check_tool assetfinder
    echo -e "${CYAN}[+] Running Assetfinder...${NC}"
    assetfinder --subs-only "$domain" | tee -a "$temp_file"
fi

if $run_amass; then
    if [ "$available_ram" -ge 3000 ]; then
        check_tool amass
        echo -e "${CYAN}[+] Running Amass (Passive)...${NC}"
        amass enum -passive -d "$domain" | tee -a "$temp_file"
    else
        echo -e "${YELLOW}[!] RAM too low (<3GB). Skipping Amass to prevent crash.${NC}" 
    fi
fi

if $run_findomain; then
    check_tool findomain
    echo -e "${CYAN}[+] Running Findomain...${NC}"
    findomain -t "$domain" -q | tee -a "$temp_file"
fi

# ==========================================
# Clean & Validate Results
# ==========================================

echo ""
echo -e "${YELLOW}[+] Cleaning Results...${NC}"

grep -i "\.$domain$" "$temp_file" | \
sed 's/^https\?:\/\///' | \
sed 's/[^a-zA-Z0-9.-]//g' | \
grep -E "^[a-zA-Z0-9.-]+\.$domain$" | \
grep -v "\.\." | \
sort -u > "$OUTPUT_DIR/subdomains.txt"

total=$(wc -l < "$OUTPUT_DIR/subdomains.txt")
rm "$temp_file"

echo -e "${GREEN}[✓] Total Unique Subdomains: $total${NC}"
echo -e "${CYAN}[✓] Saved to: $OUTPUT_DIR/subdomains.txt${NC}"

# ==========================================
# Live Check
# ==========================================

if $auto_live; then
    live_choice="y"
else
    read -p "Check live subdomains? (y/n): " live_choice
fi

if [[ "$live_choice" =~ ^[Yy]$ ]]; then

    fix_httpx

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
        echo -e "${RED}[!] No live subdomains found.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}[✓] Recon Completed Successfully.${NC}"
