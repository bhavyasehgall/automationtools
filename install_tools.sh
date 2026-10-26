#!/usr/bin/env bash
set -Eeuo pipefail

# Install system-level dependencies for AutomationTools on Debian/Kali/Ubuntu.
# Optional tools are installed from distro packages where available.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="all"

usage() {
  cat <<'EOF'
AutomationTools dependency installer

Usage:
  ./install_tools.sh [--all | --required | --module nmap|subdomains|directory]

Options:
  --all                 Install all available required and optional tools (default)
  --required            Check only the required Bash dependency
  --module nmap         Install Nmap
  --module subdomains   Install Subfinder, Assetfinder, and Findomain
  --module directory    Install Gobuster and Dirsearch
  -h, --help            Show this help

Supported systems: Kali Linux, Debian, Ubuntu (APT required).
This script installs system packages; requirements.txt is a manifest, not a pip file.
EOF
}

while (($#)); do
  case "$1" in
    --all) MODE="all"; shift ;;
    --required) MODE="required"; shift ;;
    --module)
      [[ $# -ge 2 ]] || { echo "Error: --module requires a name." >&2; exit 2; }
      case "$2" in nmap|subdomains|directory) MODE="$2" ;; *) echo "Error: unknown module '$2'." >&2; usage >&2; exit 2 ;; esac
      shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Error: unknown option '$1'." >&2; usage >&2; exit 2 ;;
  esac
done

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: this installer currently supports APT-based systems (Kali/Debian/Ubuntu)." >&2
  echo "Install tools manually using your distribution's package manager." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1 && [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Error: run as root or install sudo first." >&2
  exit 1
fi

APT=(apt-get)
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then APT=(sudo apt-get); fi

install_package() {
  local command_name="$1" package_name="$2"
  if command -v "$command_name" >/dev/null 2>&1; then
    printf '✓ %-12s already installed\n' "$command_name"
    return 0
  fi
  printf '\nInstalling %s (package: %s)...\n' "$command_name" "$package_name"
  if "${APT[@]}" install -y "$package_name"; then
    if command -v "$command_name" >/dev/null 2>&1; then
      printf '✓ %s installed successfully\n' "$command_name"
      return 0
    fi
    printf '⚠ Package installed, but command %s was not found in PATH.\n' "$command_name" >&2
  else
    printf '⚠ Could not install %s from configured APT repositories.\n' "$command_name" >&2
    printf '  You may need to enable/update your distro repositories or install it manually.\n' >&2
  fi
  return 1
}

printf 'AutomationTools dependency installer\n=====================================\n'
if [[ "$MODE" == "required" ]]; then
  if command -v bash >/dev/null 2>&1; then
    printf '✓ bash is already installed: %s\n' "$(command -v bash)"
    exit 0
  fi
  echo 'Error: Bash is required but is not installed. Install it using your system package manager.' >&2
  exit 1
fi

# Bash is normally present on Kali/Debian/Ubuntu, but install it if absent.
missing=0
if ! command -v bash >/dev/null 2>&1; then install_package bash bash || missing=1; else echo '✓ bash already installed'; fi

# Refresh package metadata once before installing selected tools.
"${APT[@]}" update

case "$MODE" in
  all)
    tools=("nmap:nmap" "subfinder:subfinder" "assetfinder:assetfinder" "findomain:findomain" "gobuster:gobuster" "dirsearch:dirsearch") ;;
  nmap)
    tools=("nmap:nmap") ;;
  subdomains)
    tools=("subfinder:subfinder" "assetfinder:assetfinder" "findomain:findomain") ;;
  directory)
    tools=("gobuster:gobuster" "dirsearch:dirsearch") ;;
esac

for entry in "${tools[@]}"; do
  command_name="${entry%%:*}"
  package_name="${entry#*:}"
  install_package "$command_name" "$package_name" || true
done

printf '\nDependency check\n-----------------\n'
for tool in bash nmap subfinder assetfinder findomain gobuster dirsearch; do
  if command -v "$tool" >/dev/null 2>&1; then printf '✓ %s\n' "$tool"; else printf '– %s not installed / unavailable from APT\n' "$tool"; fi
done
printf '\nRun ./automationtools.sh --check to review the detected dependencies.\n'
printf 'Only install and use scanning tools on systems you own or are authorized to assess.\n'
