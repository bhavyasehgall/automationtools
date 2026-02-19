AutomationTools

AutomationTools is a structured Bash-based reconnaissance automation suite designed for authorized lab environments.

It integrates network scanning, subdomain enumeration, and directory discovery into a modular toolkit focused on reproducibility, organized output management, and maintainable scripting practices.

🎯 Purpose

The objective of this project is to:

Automate common reconnaissance workflows

Standardize scan output structure

Improve reproducibility of security testing

Demonstrate modular Bash scripting practices

Maintain clean, organized result storage

This project emphasizes structured engineering over ad-hoc scripting.

⚙️ How It Works

The toolkit is divided into modular components:

1️⃣ Nmap Module

Performs host discovery and port scanning

Supports multiple scan types (quick, full, service detection, OS detection)

Streams live scan output

2️⃣ Subdomain Enumeration Module

Aggregates results from multiple enumeration tools

Cleans and deduplicates output

Optionally checks live subdomains

3️⃣ Directory Discovery Module

Performs recursive directory brute-forcing

Supports default and custom wordlists

Provides structured result logging

🗂 Project Structure

Results are stored in a standardized directory layout:

/home/kali/automationtools/
├── nmap/
├── subdomains/
└── directories/


Each module:

Prompts for target input

Displays structured target information (Domain/IP/Date)

Streams live output to the terminal

Cleans results (where applicable)

Asks before saving

Saves results with timestamped filenames

This ensures consistent and organized output management.

📌 Example Output
=========================================
 Target Information
=========================================
Domain: example.com
IP: 93.184.216.34
Date: 2026-02-19 18:42:03

[+] Running Subfinder...
api.example.com
dev.example.com

[✓] Total Unique Subdomains Found: 12
Do you want to save the results? (y/n):


Saved file example:

/home/kali/automationtools/subdomains/example.com_subdomains_20260219_184203.txt

🔧 Features

Modular reconnaissance automation

Structured result storage

Live output streaming

Clean and deduplicated enumeration results

Resource-aware execution (e.g., conditional Amass execution)

Controlled save workflow (manual confirmation before saving)

📦 Prerequisites

Ensure the following tools are installed depending on the module used:

nmap

subfinder

assetfinder

findomain

amass (optional)

httpx (for live subdomain checking)

gobuster (for directory discovery)

🚀 Installation

Clone the repository:

git clone https://github.com/bhavyasehgall/automationtools.git
cd automationtools


Make scripts executable:

chmod +x nmap.sh
chmod +x subdomains.sh
chmod +x directory.sh

▶ Usage Examples

Run Nmap module:

./nmap.sh


Run Subdomain Enumeration:

./subdomains.sh -d example.com


Run Directory Discovery:

./directory.sh

🛡 Intended for Lab Use Only

This toolkit is developed strictly for:

Authorized lab environments

Personal cybersecurity research

Educational purposes

Users are responsible for ensuring they have explicit authorization before scanning any target.

Unauthorized use may violate applicable laws and regulations.
