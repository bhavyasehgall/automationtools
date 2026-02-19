#!/bin/bash 

# ==========================================
#  AutomationTools - Directory Module
#  Author: Bhavya Sehgal
#  Description: Structured directory enumeration
#  Use: Authorized lab environments only
# ==========================================

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m'

# Default values
extensions="php,aspx,jsp,html,js"
threads=25
statuscodes="200,204,301,302,307,401,403"
wordlist=""
target=""
mode="default"

# ==============================
# Help Menu
# ==============================

show_help() {
    echo -e "${CYAN}"
    echo "Directory Enumeration Tool"
    echo "---------------------------------------"
    echo "Usage:"
    echo "  bash directories.sh -u <url> [options]"
    echo ""
    echo "Required:"
    echo "  -u <url>              Target URL"
    echo ""
    echo "Optional:"
    echo "  -w <wordlist>         Custom wordlist"
    echo "  -e <extensions>       Extensions"
    echo "  -t <threads>          Threads (default: 25)"
    echo "  -s <statuscodes>      Status codes to include"
    echo "  -h                    Show help"
    echo -e "${NC}"
    exit 0
}

# ==============================
# Tool Checker
# ==============================

check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[!] $1 is not installed.${NC}"
        return 1
    fi
    return 0
}

# ==============================
# Parse Arguments
# ==============================

while getopts ":u:w:e:t:s:h" opt; do
  case ${opt} in
    u ) target=$OPTARG ;;
    w ) wordlist=$OPTARG; mode="custom" ;;
    e ) extensions=$OPTARG ;;
    t ) threads=$OPTARG ;;
    s ) statuscodes=$OPTARG ;;
    h ) show_help ;;
    \? ) echo -e "${RED}Invalid option: -$OPTARG${NC}" ; exit 1 ;;
  esac
done

# ==============================
# Ask Target if not provided
# ==============================

if [ -z "$target" ]; then
    echo ""
    read -p "Enter Target URL (https://example.com): " target
fi

if [ -z "$target" ]; then
    echo -e "${RED}[!] Target URL is required.${NC}"
    exit 1
fi

# Remove trailing slash
target=${target%/}

# Extract domain
domain=$(echo "$target" | sed 's|https://||;s|http://||;s|/.*||')

# Resolve IP
ip=$(dig +short "$domain" | head -n 1)

# Timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
date_now=$(date +"%Y-%m-%d %H:%M:%S")

# ==============================
# Create Structured Directories
# ==============================

base_dir="/home/kali/automationtools"
mkdir -p "$base_dir/directories"

# ==============================
# Display Target Info
# ==============================

echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN} Target Information${NC}"
echo -e "${CYAN}=========================================${NC}"
echo -e "${YELLOW}Target:${NC} $target"
echo -e "${YELLOW}IP:${NC} ${ip:-Not Resolved}"
echo -e "${YELLOW}Date:${NC} $date_now"
echo ""

# ==============================
# Tool Selection Menu
# ==============================

echo -e "${CYAN}Choose Directory Enumeration Tool:${NC}"
echo "1) Gobuster"
echo "2) Dirsearch"
echo "0) Exit"
echo ""
read -p "Select option: " tool_choice

case $tool_choice in
    1)
        if check_tool gobuster; then

            echo ""
            echo -e "${CYAN}Choose Gobuster Mode:${NC}"
            echo "1) Simple Scan"
            echo "2) Recursive Scan"
            echo ""
            read -p "Select option: " gobuster_mode

            # Default wordlist if none provided
            if [ -z "$wordlist" ]; then
                wordlist="/usr/share/wordlists/dirb/common.txt"
            fi

            output_file="$base_dir/directories/${domain}_gobuster_$timestamp.txt"

            case $gobuster_mode in
                1)
                    echo -e "${YELLOW}[+] Running Gobuster (Simple Mode)...${NC}"
                    gobuster dir \
                    -u "$target" \
                    -w "$wordlist" \
                    -x "$extensions" \
                    -t "$threads" \
                    -q | tee -a "$output_file"
                    ;;
                2)
                    echo -e "${YELLOW}[+] Running Gobuster (Recursive Mode)...${NC}"
                    gobuster dir \
                    -u "$target" \
                    -w "$wordlist" \
                    -x "$extensions" \
                    -t "$threads" \
                    -r \
                    -q | tee -a "$output_file"
                    ;;
                *)
                    echo -e "${RED}[!] Invalid option.${NC}"
                    exit 1
                    ;;
            esac
        else
            exit 1
        fi
        ;;

    2)
        if check_tool dirsearch; then

            output_file="$base_dir/directories/${domain}_dirsearch_$timestamp.txt"

            echo -e "${YELLOW}[+] Running Dirsearch (Recursive Mode)...${NC}"
            dirsearch -u "$target" \
            -w "$wordlist" \
            -e "$extensions" \
            -t "$threads" \
            --recursive \
            --include-status="$statuscodes" \
            --format=plain \
            --output="$output_file"
        else
            exit 1
        fi
        ;;

    0)
        exit 0
        ;;

    *)
        echo -e "${RED}[!] Invalid option.${NC}"
        exit 1
        ;;
esac

# ==============================
# Cleanup Empty File
# ==============================

echo ""
echo -e "${GREEN}[+] Scan Completed.${NC}"

if [ ! -s "$output_file" ]; then
    rm -f "$output_file"
    echo -e "${RED}[!] No results found. Empty file removed.${NC}"
else
    echo -e "${GREEN}[+] Results saved to:${NC} $output_file"
fi

echo ""
