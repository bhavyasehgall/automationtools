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
