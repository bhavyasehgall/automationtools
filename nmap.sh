#!/bin/bash

# ==========================================
#  AutomationTools - Nmap Module
#  Author: Bhavya Sehgal
#  Description: Structured Nmap automation
#  Use: Authorized lab environments only
# ==========================================

set -euo pipefail

# ==============================
# Colors
# ==============================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# ==============================
# Tool Check
# ==============================
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}[!] Nmap is not installed. Install using: sudo apt install nmap${NC}"
    exit 1
fi

# ==============================
# Target Input
# ==============================
read -p "Enter Target IP or Domain: " target

safe_target=$(echo "$target" | tr -cd '[:alnum:]._-')

if [ -z "$safe_target" ]; then
    echo -e "${RED}[!] Invalid target input.${NC}"
    exit 1
fi

# ==============================
# Directory Setup
# ==============================
BASE_DIR="results/$safe_target/nmap"
mkdir -p "$BASE_DIR"

# ==============================
# Root Check
# ==============================
is_root() {
    [ "$EUID" -eq 0 ]
}

# ==============================
# Help Menu
# ==============================
show_help() {
    echo ""
    echo -e "${CYAN}=========== HELP MENU ===========${NC}"
    echo "This tool automates different Nmap scans."
    echo ""
    echo "2) Host Discovery"
    echo "   - Checks if host is alive (Ping scan)"
    echo "   - Command: nmap -sn <target>"
    echo ""
    echo "3) Quick Scan"
    echo "   - Scans top 1000 common ports"
    echo "   - Command: nmap -T4 <target>"
    echo ""
    echo "4) Full Port Scan"
    echo "   - Scans all 65535 ports"
    echo "   - Command: nmap -p- -T4 <target>"
    echo ""
    echo "5) Service & Version Detection"
    echo "   - Detects service versions"
    echo "   - Command: nmap -sV -sC <target>"
    echo ""
    echo "6) OS Detection"
    echo "   - Attempts OS fingerprinting (needs sudo)"
    echo "   - Command: sudo nmap -O <target>"
    echo ""
    echo "7) Custom Scan"
    echo "   - Run custom Nmap arguments"
    echo ""
    echo -e "${YELLOW}⚠ Use only on authorized systems.${NC}"
    echo -e "${CYAN}=================================${NC}"
}

# ==============================
# Scan Function
# ==============================
run_scan() {

    local command="$1"
    local use_sudo="$2"

    temp_file=$(mktemp)

    echo -e "${YELLOW}[+] Running Scan...${NC}"

    {
        echo "Scan Date: $(date)"
        echo "Target: $target"
        echo "Command: nmap $command $target"
        echo "========================================="
        echo ""
    } > "$temp_file"

    if [ "$use_sudo" = "true" ]; then
        sudo nmap $command "$target" | tee -a "$temp_file"
    else
        nmap $command "$target" | tee -a "$temp_file"
    fi

    status=$?

    if [ $status -ne 0 ]; then
        rm "$temp_file"
        echo -e "${RED}[!] Scan failed.${NC}"
        return
    fi

    echo ""
    echo -e "${GREEN}[✓] Scan completed successfully.${NC}"
    echo ""

    read -p "Do you want to save the results? (y/n): " save_choice

    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
        read -p "Enter file name (without extension): " filename
        filename=${filename:-scan_$(date +%Y%m%d_%H%M%S)}
        mv "$temp_file" "$BASE_DIR/$filename.txt"
        echo -e "${GREEN}[✓] Saved as $BASE_DIR/$filename.txt${NC}"
    else
        rm "$temp_file"
        echo -e "${YELLOW}[!] Results not saved.${NC}"
    fi
}

# ==============================
# Main Menu
# ==============================
while true
do
    echo ""
    echo -e "${CYAN}=========== Nmap Scan Menu ===========${NC}"
    echo "1) Help"
    echo "2) Host Discovery"
    echo "3) Quick Scan"
    echo "4) Full Port Scan"
    echo "5) Service & Default Script Scan"
    echo "6) OS Detection"
    echo "7) Custom Scan"
    echo "0) Exit"
    echo "======================================="
    read -p "Choose an option: " choice

    case $choice in
        1)
            show_help
            ;;
        2)
            run_scan "-sn" "false"
            ;;
        3)
            run_scan "-T4" "false"
            ;;
        4)
            run_scan "-p- -T4" "false"
            ;;
        5)
            run_scan "-sV -sC" "false"
            ;;
        6)
            if is_root; then
                run_scan "-O" "false"
            else
                run_scan "-O" "true"
            fi
            ;;
        7)
            read -p "Enter custom Nmap arguments (exclude 'nmap' and target): " custom_args
            if [[ "$custom_args" == *"nmap"* ]] || [[ "$custom_args" == *"$target"* ]]; then
                echo -e "${RED}[!] Invalid custom arguments.${NC}"
            else
                run_scan "$custom_args" "false"
            fi
            ;;
        0)
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid option. Try again.${NC}"
            ;;
    esac
done
