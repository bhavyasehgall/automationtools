# AutomationTools

**AutomationTools** is a structured Bash-based reconnaissance automation suite designed for authorized lab environments.

It integrates network scanning, subdomain enumeration, and directory discovery into a modular toolkit focused on reproducibility, organized output management, and maintainable scripting practices.

This project prioritizes structured engineering over ad-hoc scripting.

---

## 📌 Overview

AutomationTools provides a consistent and modular approach to reconnaissance automation.  
Each module operates independently while maintaining standardized output formatting and storage structure.

The toolkit ensures:

- Structured target reporting  
- Clean result handling  
- Controlled save workflow  
- Reproducible execution patterns  

---

## 🎯 Purpose

The objectives of this project are:

- Automate common reconnaissance workflows  
- Standardize output management  
- Improve reproducibility in security testing  
- Demonstrate modular Bash scripting practices  
- Maintain organized and timestamped result storage  

This repository reflects structured system design rather than one-off automation scripts.

---

## 🏗 Architecture

The toolkit is divided into independent modules:

- `nmap.sh` — Network scanning module  
- `subdomains.sh` — Subdomain enumeration module  
- `directory.sh` — Directory discovery module  

Each module follows the same execution lifecycle:

1. Prompt for target  
2. Display structured target information (Domain / IP / Date)  
3. Execute tools with live output streaming  
4. Clean and process results (if applicable)  
5. Ask user confirmation before saving  
6. Save results using timestamped filenames  

This ensures consistency across the entire suite.

---

## ⚙️ Modules

### 1️⃣ Nmap Module

**Performs:**

- Host discovery  
- Port scanning  
- Service detection  
- OS detection  

**Features:**

- Multiple scan modes (quick / full / service / OS)  
- Live streaming output  
- Structured result storage  

---

### 2️⃣ Subdomain Enumeration Module

**Integrates:**

- subfinder  
- assetfinder  
- findomain  
- amass (optional, resource-aware)  

**Capabilities:**

- Aggregates tool results  
- Cleans and deduplicates output  
- Optional live subdomain checking (via httpx)  
- Structured summary output  

---

### 3️⃣ Directory Discovery Module

**Supports:**

- gobuster  
- dirsearch (if configured)  

**Features:**

- Recursive scanning option  
- Default or custom wordlist support  
- Live terminal streaming  
- Organized, timestamped output  

---

## 🔄 Workflow

Example execution flow:

1. Run the desired module  
2. Enter target  
3. View structured target details  
4. Observe live scanning progress  
5. Review summarized results  
6. Confirm whether to save  
7. Results stored in standardized directory  

---

## 🗂 Project Structure

```bash
/home/kali/automationtools/
├── nmap/
├── subdomains/
└── directories/
```

Example Savled Files:

```bash
nmap/
└── example.com_info_20260219_184203.txt

subdomains/
└── example.com_subdomains_20260219_184203.txt

directories/
└── example.com_gobuster_20260219_184203.txt
```

---
## Example Output:

```bash
=========================================
Target Information
=========================================

Domain: example.com
IP: 93.184.216.34
Date: 2026-02-19 18:42:03

[+] Running Subfinder...
api.example.com
dev.example.com

[+] Running Findomain...
mail.example.com

[✓] Total Unique Subdomains Found: 12

Do you want to save the results? (y/n):
```

Saved Files Examples:

```bash
/home/kali/automationtools/subdomains/example.com_subdomains_20260219_184203.txt
```
---

## 🔧 Features

- Modular reconnaissance automation  
- Structured and timestamped output storage  
- Live terminal output streaming  
- Deduplicated enumeration results  
- Optional live subdomain validation  
- Resource-aware execution  
- Manual confirmation before saving  
- Consistent output formatting across modules  

---

## 📦 Prerequisites

Ensure the following tools are installed and available in your system PATH:

- `nmap`  
- `subfinder`  
- `assetfinder`  
- `findomain`  
- `amass` (optional)  
- `httpx` (for live subdomain checking)  
- `gobuster`  
- `dirsearch` (optional)  

---

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/bhavyasehgall/automationtools.git
cd automationtools
```

Make scripts Executable:

```bash
chmod +x nmap.sh
chmod +x subdomains.sh
chmod +x directory.sh
```

---

## ▶ Usage

Run the Nmap module:

```./nmap.sh```


Run Subdomain Enumeration:

```./subdomains.sh```


Run Directory Discovery:

```./directory.sh```

Each module will prompt for required input interactively.
---
