# AutomationTools

**AutomationTools** is a modular Bash-based reconnaissance automation toolkit designed for authorized security testing, cybersecurity labs, and learning environments.

It brings together common reconnaissance workflows such as **network scanning, passive subdomain enumeration, and web directory discovery** behind a single command-line interface.

The project focuses on **security automation, reusable Bash components, input validation, dependency awareness, and organized result management** rather than simply executing individual security tools.

> **Current Version:** `v2.0.0`

---

## ⚠️ Authorized Use Only

AutomationTools is intended for:

* Authorized penetration testing
* Personal security labs
* CTFs and training environments
* Systems you own or have explicit permission to test

Do **not** use this toolkit against systems without authorization.

---

## ✨ Features

* Modular Bash architecture
* Central command-line interface
* Network reconnaissance with Nmap
* Passive subdomain enumeration
* Directory and web content discovery
* Dependency detection
* Target validation
* URL and wordlist validation
* Configurable Nmap scan modes
* Multiple enumeration tools
* Centralized timestamped result storage
* Consistent logging and output handling
* Interactive execution mode
* `--help` and `--version` support

---

## 🏗️ Architecture

```text
AutomationTools/
│
├── automationtools.sh
│
├── lib/
│   ├── common.sh
│   ├── dependencies.sh
│   └── validation.sh
│
├── modules/
│   ├── nmap.sh
│   ├── subdomains.sh
│   └── directory.sh
│
├── results/
│   └── .gitkeep
│
├── README.md
└── LICENSE
```

### Core Controller

`automationtools.sh` is the main entry point.

It handles:

* Command-line argument parsing
* Module selection
* Target validation
* Dependency checks
* Result initialization
* Module execution
* Help and version information

### Shared Libraries

#### `lib/common.sh`

Provides reusable functionality such as:

* Logging
* Status messages
* Error handling
* Timestamp generation
* Result directory creation
* Filename sanitization
* Shared utility functions

#### `lib/dependencies.sh`

Checks whether supported security tools are available before execution.

Supported tools include:

* Nmap
* Subfinder
* Assetfinder
* Findomain
* Amass
* Gobuster
* Dirsearch
* httpx

Not every dependency is required for every module.

#### `lib/validation.sh`

Provides input validation for:

* Domains
* IPv4 addresses
* URLs
* Wordlists
* Target formats

---

# 🔎 Modules

## 1. Nmap

The Nmap module performs network reconnaissance using configurable scan modes.

### Quick Scan

```bash
./automationtools.sh -t 192.168.1.1 -m nmap --nmap-mode quick
```

### Service Detection

```bash
./automationtools.sh -t 192.168.1.1 -m nmap --nmap-mode service
```

### Full TCP Scan

```bash
./automationtools.sh -t 192.168.1.1 -m nmap --nmap-mode full
```

---

## 2. Subdomain Enumeration

The subdomain module can combine results from multiple passive enumeration tools.

Supported tools include:

* Subfinder
* Assetfinder
* Findomain
* Amass

Example:

```bash
./automationtools.sh -t example.com -m subdomains
```

The workflow can:

1. Validate the target
2. Run available enumeration tools
3. Collect discovered subdomains
4. Remove duplicates
5. Sort results
6. Optionally identify live hosts
7. Store results in the run directory

---

## 3. Directory Discovery

The directory discovery module performs web content discovery against an authorized URL.

Supported tools:

* Gobuster
* Dirsearch

Example:

```bash
./automationtools.sh -t http://example.com -m directory
```

Custom wordlist:

```bash
./automationtools.sh \
    -t http://example.com \
    -m directory \
    --wordlist /path/to/wordlist.txt
```

---

# 🚀 Installation

### Requirements

* Linux
* Bash
* Required security tools for the selected module

Kali Linux is recommended because many of the supported security tools are readily available.

### Clone

```bash
git clone https://github.com/bhavyasehgall/automationtools.git
cd automationtools
```

Make the main script executable:

```bash
chmod +x automationtools.sh
```

If necessary:

```bash
chmod +x lib/*.sh
chmod +x modules/*.sh
```

---

# ▶️ Usage

Display help:

```bash
./automationtools.sh --help
```

Display version:

```bash
./automationtools.sh --version
```

Check dependencies:

```bash
./automationtools.sh --check
```

Run Nmap:

```bash
./automationtools.sh -t 192.168.1.1 -m nmap
```

Run subdomain enumeration:

```bash
./automationtools.sh -t example.com -m subdomains
```

Run directory discovery:

```bash
./automationtools.sh -t http://example.com -m directory
```

Run a complete workflow:

```bash
./automationtools.sh -t example.com -m full
```

Interactive mode:

```bash
./automationtools.sh --interactive
```

---

# 📁 Results

Results are stored under:

```text
results/
└── <target>_<timestamp>/
    ├── nmap/
    ├── subdomains/
    └── directory/
```

This keeps individual reconnaissance runs separated and easier to review.

---

# 🧠 What I Learned

This project helped me practice:

* Bash scripting
* Shell argument parsing
* Modular script design
* Input validation
* Dependency management
* Security-tool integration
* File and directory handling
* Automation workflows
* Structured result management
* Maintainable security scripting

---

# 🛣️ Roadmap

Potential future improvements:

* Automated Bash syntax testing
* ShellCheck integration
* More reconnaissance modules
* Improved output formats
* JSON result generation
* Better logging
* More robust test coverage
* GitHub Actions CI

---

# 📜 License

This project is licensed under the **MIT License**.

See [`LICENSE`](LICENSE) for details.

---

## 👤 Author

**Bhavya Sehgal**

Cybersecurity | VAPT | Security Automation | Linux

GitHub: https://github.com/bhavyasehgall
