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
# Check Nmap
# ==============================
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}[!] Nmap is not installed. Install using: sudo apt install nmap${NC}"
    exit 1
fi

# ==============================
# Target Input
# ==============================
read -p "Enter Target Domain or IP: " target

safe_target=$(echo "$target" | tr -cd '[:alnum:]._-')

if [ -z "$safe_target" ]; then
    echo -e "${RED}[!] Invalid target input.${NC}"
    exit 1
fi

ip=$(dig +short "$safe_target" | head -n 1 || true)
date_now=$(date +"%Y-%m-%d %H:%M:%S")
timestamp=$(date +"%Y%m%d_%H%M%S")

# ==============================
# Directory Structure
# ==============================
BASE_DIR="/home/kali/automationtools"
NMAP_DIR="$BASE_DIR/nmap"
mkdir -p "$NMAP_DIR"

# ==============================
# Display Target Info
# ==============================
echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN} Target Information${NC}"
echo -e "${CYAN}=========================================${NC}"
echo -e "${YELLOW}Target:${NC} $safe_target"
echo -e "${YELLOW}IP:${NC} ${ip:-Not Resolved}"
echo -e "${YELLOW}Date:${NC} $date_now"
echo ""

# ==============================
# Root Check
# ==============================
is_root() {
    [ "$EUID" -eq 0 ]
}

# ==============================
# Scan Function
# ==============================
run_scan() {

    local command="$1"
    local label="$2"
    local use_sudo="$3"

    temp_file=$(mktemp)

    echo -e "${YELLOW}[+] Running $label...${NC}"
    echo ""

    {
        echo "========================================="
        echo "Scan Date: $date_now"
        echo "Target: $safe_target"
        echo "IP: ${ip:-Not Resolved}"
        echo "Command: nmap $command $safe_target"
        echo "========================================="
        echo ""
    } > "$temp_file"

    if [ "$use_sudo" = "true" ]; then
        sudo nmap $command "$safe_target" | tee -a "$temp_file"
    else
        nmap $command "$safe_target" | tee -a "$temp_file"
    fi

    echo ""
    echo -e "${GREEN}[✓] Scan Completed${NC}"
    echo ""

    read -p "Do you want to save the results? (y/n): " save_choice

    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
        output_file="$NMAP_DIR/${safe_target}_${label}_${timestamp}.txt"
        mv "$temp_file" "$output_file"
        echo -e "${GREEN}[✓] Saved to: $output_file${NC}"
    else
        rm -f "$temp_file"
        echo -e "${YELLOW}[!] Results discarded.${NC}"
    fi

    echo ""
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
# Main Menu
# ==============================
while true
do
    echo -e "${CYAN}=========== Nmap Scan Menu ===========${NC}"
    echo "1) Help"
    echo "2) Host Discovery"
    echo "3) Quick Scan"
    echo "4) Full Port Scan"
    echo "5) Service & Default Script Scan"
    echo "6) OS Detection"
    echo "7) Aggressive Scan"
    echo "8) Custom Scan"
    echo "0) Exit"
    echo "======================================="
    read -p "Choose an option: " choice

    case $choice in
        1)
            show_help
            ;;
        2)
            run_scan "-sn" "host_discovery" "false"
            ;;
        3)
            run_scan "-T4" "quick_scan" "false"
            ;;
        4)
            run_scan "-p- -T4" "full_port_scan" "false"
            ;;
        5)
            run_scan "-sV -sC" "service_scan" "false"
            ;;
        6)
            if is_root; then
                run_scan "-O" "os_detection" "false"
            else
                run_scan "-O" "os_detection" "true"
            fi
            ;;
        7)
            if is_root; then
                run_scan "-A -T4" "aggressive_scan" "false"
            else
                run_scan "-A -T4" "aggressive_scan" "true"
            fi
            ;;
        8)
            read -p "Enter custom Nmap arguments (exclude 'nmap' and target): " custom_args
            if [[ "$custom_args" == *"nmap"* ]] || [[ "$custom_args" == *"$safe_target"* ]]; then
                echo -e "${RED}[!] Invalid custom arguments.${NC}"
            else
                run_scan "$custom_args" "custom_scan" "false"
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
