#!/bin/bash

# ==============================
#   Directory Enumeration Tool
# ==============================

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
    echo "  ./directories.sh -u <url> [options]"
    echo ""
    echo "Required:"
    echo "  -u <url>              Target URL"
    echo ""
    echo "Optional:"
    echo "  -w <wordlist>         Custom wordlist"
    echo "  -e <extensions>       Extensions (comma separated)"
    echo "  -t <threads>          Threads (default: 25)"
    echo "  -s <statuscodes>      Status codes to include"
    echo "  -h                    Show help"
    echo ""
    echo "Example:"
    echo "  bash directories.sh -u https://example.com"
    echo "  ./directories.sh -u https://example.com"
    echo -e "${NC}"
    exit 0
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
# Interactive Mode (if no -u)
# ==============================

if [ -z "$target" ]; then
    echo ""
    read -p "Enter Target URL (https://example.com): " target
    echo ""
fi

# Validation
if [ -z "$target" ]; then
    echo -e "${RED}[!] Target URL is required.${NC}"
    exit 1
fi

# Remove trailing slash
target=${target%/}

# Output directory
output_dir="$HOME/reports"
mkdir -p "$output_dir"

clean_name=$(echo "$target" | sed 's|https://||;s|http://||;s|/|_|g')
timestamp=$(date +"%Y%m%d_%H%M%S")
output_file="$output_dir/${clean_name}_$timestamp.txt"

echo -e "${GREEN}[+] Starting Recursive Directory Scan...${NC}"
echo -e "${YELLOW}[+] Target: $target${NC}"
echo ""

# ==============================
# Run Scan
# ==============================

if [ "$mode" == "custom" ] && [ -n "$wordlist" ]; then

    dirsearch -u "$target" \
    -w "$wordlist" \
    -e "$extensions" \
    -t "$threads" \
    --recursive \
    --include-status="$statuscodes" \
    --format=plain \
    --output="$output_file"

else

    dirsearch -u "$target" \
    -e "$extensions" \
    -t "$threads" \
    --recursive \
    --include-status="$statuscodes" \
    --format=plain \
    --output="$output_file"

fi

echo ""
echo -e "${GREEN}[+] Scan Completed.${NC}"

# Remove empty file if no results
if [ ! -s "$output_file" ]; then
    rm "$output_file"
    echo -e "${RED}[!] No results found. Empty file removed.${NC}"
else
    echo -e "${GREEN}[+] Results saved to: $output_file${NC}"
fi

echo ""

