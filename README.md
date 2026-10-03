# AutomationTools

**AutomationTools** is a modular Bash-based security automation toolkit for authorized reconnaissance and security testing environments.

It brings together **network scanning, passive subdomain enumeration, and web directory discovery** through a centralized command-line interface.

The project focuses on **modularity, reusable Bash components, dependency awareness, input validation, and organized result management**.

> **Current Version: v2.0.0**

---

## 📌 Overview

AutomationTools provides a structured way to perform common reconnaissance tasks without maintaining a collection of unrelated scripts.

Version 2 introduces a modular architecture built around:

* Centralized command-line control
* Independent reconnaissance modules
* Shared Bash libraries
* Dependency checking
* Target and input validation
* Configurable Nmap scan modes
* Multiple subdomain enumeration tools
* Gobuster / Dirsearch directory discovery
* Centralized result storage
* Consistent logging and output handling

The project is primarily intended for **cybersecurity learning, authorized testing, CTFs, and controlled lab environments**.

---

## 🎯 Objectives

AutomationTools was built to practice practical Bash scripting and security automation concepts.

The main objectives are to:

* Automate repetitive reconnaissance tasks
* Build reusable Bash components
* Separate core logic from individual modules
* Validate user input before execution
* Detect required and optional dependencies
* Maintain organized and consistent results
* Provide reproducible command-line workflows
* Integrate multiple security tools into one workflow
* Practice maintainable security-tool integration

The goal is not simply to execute security tools, but to demonstrate how multiple tools can be organized into a maintainable automation workflow.

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

### `automationtools.sh`

The main entry point of the toolkit.

It is responsible for:

* Parsing command-line arguments
* Selecting modules
* Validating required inputs
* Initializing result directories
* Loading shared libraries
* Coordinating module execution
* Providing help and version information

---

# 📁 Shared Libraries

## `lib/common.sh`

Contains reusable functionality shared across the toolkit.

Examples include:

* Logging functions
* Status messages
* Error handling
* Timestamp generation
* Result-directory handling
* Filename sanitization
* Common utility functions

---

## `lib/dependencies.sh`

Handles dependency detection and availability checks.

The toolkit can determine whether supported security tools are available before a module executes.

Supported tools include:

* Nmap
* Subfinder
* Assetfinder
* Findomain
* Amass
* Gobuster
* Dirsearch
* httpx

Some dependencies are optional and are used when available.

---

## `lib/validation.sh`

Provides input validation for module operations.

Validation can include:

* Domain validation
* IPv4 validation
* URL validation
* Wordlist validation
* Target format checking

This helps prevent invalid input from being passed to underlying security tools.

---

# ⚙️ Modules

## 1. Nmap Module

**Location:**

```text
modules/nmap.sh
```

The Nmap module performs network reconnaissance using configurable scan modes.

### Quick Mode

Designed for a faster scan of common ports.

```bash
./automationtools.sh \
    -t 192.168.1.1 \
    -m nmap \
    --nmap-mode quick
```

### Service Mode

Performs service and version detection against common ports.

```bash
./automationtools.sh \
    -t 192.168.1.1 \
    -m nmap \
    --nmap-mode service
```

### Full Mode

Scans all TCP ports with service detection.

```bash
./automationtools.sh \
    -t 192.168.1.1 \
    -m nmap \
    --nmap-mode full
```

---

# 2. Subdomain Enumeration Module

**Location:**

```text
modules/subdomains.sh
```

The subdomain module aggregates results from multiple passive enumeration tools when they are available.

### Integrated Tools

* Subfinder
* Assetfinder
* Findomain
* Amass

Amass is treated as an optional, potentially resource-intensive dependency.

### Workflow

The module can:

1. Validate the target
2. Run available enumeration tools
3. Collect discovered subdomains
4. Remove duplicate results
5. Sort the output
6. Optionally identify live hosts using `httpx`
7. Store results in the centralized results directory

### Example

```bash
./automationtools.sh \
    -t example.com \
    -m subdomains
```

---

# 3. Directory Discovery Module

**Location:**

```text
modules/directory.sh
```

The directory discovery module performs web content discovery against an authorized URL.

### Supported Tools

* Gobuster
* Dirsearch

Gobuster is preferred when available, with Dirsearch available as an alternative.

### Example

```bash
./automationtools.sh \
    -u http://example.com \
    -m directory
```

### Custom Wordlist

A custom wordlist can be supplied with:

```bash
./automationtools.sh \
    -u http://example.com \
    -m directory \
    -w /path/to/wordlist.txt
```

The module can also detect common wordlists available in a Kali Linux environment.

---

# 🚀 Installation

## Requirements

AutomationTools is designed for Linux environments, particularly cybersecurity distributions such as **Kali Linux**.

### Core Requirements

* Bash
* Linux environment

### Security Tools

Depending on the module being used:

* Nmap
* Subfinder
* Assetfinder
* Findomain
* Amass
* Gobuster
* Dirsearch
* httpx

Not every tool is required for every module.

AutomationTools includes dependency checking to identify which supported tools are currently available.

---

## Clone the Repository

### SSH

```bash
git clone git@github.com:bhavyasehgall/automationtools.git
```

### HTTPS

```bash
git clone https://github.com/bhavyasehgall/automationtools.git
```

Enter the project directory:

```bash
cd automationtools
```

Make the main controller executable:

```bash
chmod +x automationtools.sh
```

If required, restore permissions for libraries and modules:

```bash
chmod +x lib/*.sh
chmod +x modules/*.sh
```

---

# ▶️ Usage

The main interface is:

```bash
./automationtools.sh
```

## Display Help

```bash
./automationtools.sh --help
```

or:

```bash
./automationtools.sh -h
```

---

## Display Version

```bash
./automationtools.sh --version
```

---

## Check Dependencies

```bash
./automationtools.sh --check
```

This checks the availability of supported security tools and reports which dependencies are installed.

---

# 🧭 Command-Line Options

| Option           | Description                         |
| ---------------- | ----------------------------------- |
| `-t, --target`   | Target domain or IP address         |
| `-u, --url`      | Target URL                          |
| `-m, --module`   | Module to execute                   |
| `--nmap-mode`    | Nmap scan mode                      |
| `-w, --wordlist` | Custom directory-discovery wordlist |
| `-v, --verbose`  | Enable verbose output               |
| `-c, --check`    | Check available dependencies        |
| `-h, --help`     | Display help                        |
| `--version`      | Display version                     |

### Available Modules

```text
nmap
subdomains
directory
full
```

---

# 🔄 Example Workflows

## Network Reconnaissance

```bash
./automationtools.sh \
    -t 192.168.1.10 \
    -m nmap \
    --nmap-mode service
```

---

## Passive Subdomain Enumeration

```bash
./automationtools.sh \
    -t example.com \
    -m subdomains
```

---

## Directory Discovery

```bash
./automationtools.sh \
    -u http://example.com \
    -m directory
```

---

## Full Workflow

The `full` option can execute the toolkit's available reconnaissance workflow against a target where supported.

```bash
./automationtools.sh \
    -t example.com \
    -m full
```

> Only use the toolkit against systems, networks, domains, and applications for which you have explicit authorization.

---

# 📂 Results

AutomationTools stores generated output inside:

```text
results/
```

This keeps generated scan data separate from the source code and helps maintain an organized project structure.

A typical project state may look like:

```text
AutomationTools/
│
├── automationtools.sh
├── lib/
├── modules/
│
└── results/
    ├── target_nmap_*.txt
    ├── target_subdomains_*.txt
    └── target_directory_*.txt
```

Result filenames include target information and timestamps where applicable.

The repository contains a `.gitkeep` file inside `results/` so the directory structure remains available in Git while generated scan results remain local.

---

# 🧪 Validation & Testing

Before running a module, AutomationTools performs input validation appropriate to the selected operation.

Examples include:

* Domain validation
* IPv4 validation
* URL validation
* Wordlist path validation
* Dependency checks

### Bash Syntax Checks

Individual files can also be checked manually:

```bash
bash -n automationtools.sh
bash -n lib/*.sh
bash -n modules/*.sh
```

---

# 🛠️ Design Principles

AutomationTools is built around several engineering principles.

### Modularity

Each major reconnaissance capability is isolated into its own module.

### Reusability

Common functionality is placed into shared libraries instead of being duplicated across scripts.

### Validation

User input is validated before being passed to security tools.

### Dependency Awareness

The toolkit detects available tools instead of assuming every dependency is installed.

### Maintainability

The project separates responsibilities:

```text
Controller
    ↓
Shared Libraries
    ↓
Security Modules
    ↓
Results
```

This makes individual components easier to understand, test, and modify.

### Reproducibility

Structured command-line options and standardized result handling make repeated testing more consistent.

---

# 🔐 Authorized Use

AutomationTools is intended for:

* Personal cybersecurity laboratories
* CTF and training environments
* Systems you own
* Applications you are authorized to test
* Educational cybersecurity research
* Controlled security assessments

**Do not use this toolkit against systems, networks, domains, or applications without explicit authorization.**

The responsibility for obtaining appropriate authorization and complying with applicable laws and regulations rests with the user.

---

# 🗺️ Roadmap

Potential future improvements include:

* JSON result export
* Configurable output formats
* Improved logging levels
* Configuration file support
* Additional reconnaissance modules
* Improved dependency management
* Better result parsing and summaries
* Unit-style tests for Bash components
* Automated CI syntax testing
* Optional report generation
* Improved module/plugin registration

The roadmap may change as the project develops.

---

# 📜 Version History

## v2.0.0

Major architectural refactor introducing:

* Central CLI controller
* Modular project structure
* Shared Bash libraries
* Dependency checking
* Input validation
* Centralized result handling
* Configurable Nmap modes
* Multi-tool subdomain enumeration
* Gobuster / Dirsearch directory discovery
* Improved maintainability

## v1.0.0

Initial AutomationTools release containing independent Bash scripts for:

* Nmap scanning
* Subdomain enumeration
* Directory discovery

The V1 implementation remains available in Git history through the `v1.0.0` tag.

---

# 👨‍💻 Author

**Bhavya Sehgal**

Cybersecurity Student | Bash & Security Automation

GitHub:
https://github.com/bhavyasehgall

---

# 📄 License

This project is licensed under the **MIT License**.

See [`LICENSE`](LICENSE) for details.
