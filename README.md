# AutomationTools

**AutomationTools**  is a structured Bash-based reconnaissance automation suite designed for authorized lab environments.

It integrates network scanning, subdomain enumeration, and directory discovery into a modular toolkit focused on reproducibility, organized output management, and maintainable scripting practices.

This project prioritizes structured engineering over ad-hoc scripting.

---

# 📌 Overview

**AutomationTools** provides a consistent and modular approach to reconnaissance automation.
Each module operates independently while maintaining standardized output formatting and storage structure.

The toolkit ensures:

- Structured target reporting

- Clean result handling

- Controlled save workflow

- Reproducible execution patterns

---

# 🎯 Purpose

The objectives of this project are:

- Automate common reconnaissance workflows

- Standardize output management

- Improve reproducibility in security testing

- Demonstrate modular Bash scripting practices

- Maintain organized and timestamped result storage

This repository reflects structured system design rather than one-off automation scripts.

---

# 🏗 Architecture

The toolkit is divided into independent modules:

- nmap.sh — Network scanning module

- subdomains.sh — Subdomain enumeration module

- directory.sh — Directory discovery module

Each module follows the same execution lifecycle:

- Prompt for target

- Display structured target information (Domain / IP / Date)

- Execute tools with live output streaming

- Clean and process results (if applicable)

- Ask user confirmation before saving

- Save results using timestamped filenames

This ensures consistency across the entire suite.

---
# ⚙️ Modules

# 1️⃣ Nmap Module

Performs:

- Host discovery

- Port scanning

-Service detection

- OS detection

Features:

- Multiple scan modes (quick / full / service / OS)

- Live streaming output

- Structured result storage
---
# 2️⃣ Subdomain Enumeration Module

Integrates:

- subfinder

- assetfinder

- findomain

- amass (optional, resource-aware)

Capabilities:

- Aggregates tool results

- Cleans and deduplicates output

- Optional live subdomain checking (via httpx)

- Structured summary output
---
# 3️⃣ Directory Discovery Module

Supports:

- gobuster

- dirsearch (if configured)

Features:

- Recursive scanning option

- Default or custom wordlist support

- Live terminal streaming

- Organized, timestamped output
---
# 🔄 Workflow

Example execution flow:

Run module

Enter target

View structured target details

Observe live scanning progress

Review summarized results

Confirm whether to save

Results stored in standardized directory
---
