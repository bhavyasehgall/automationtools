# AutomationTools

**AutomationTools** is a modular Bash-based reconnaissance workflow for authorized security testing, personal labs, and learning environments. It provides a single CLI for Nmap scans, passive subdomain enumeration, and web directory discovery.

> **Version:** `2.1.0`  
> **Authorized use only:** Run scans only against systems you own or have explicit permission to test.

## Features

- Modular Bash architecture with shared validation and logging helpers
- Nmap modes: `quick`, `service`, and `full`
- Passive subdomain enumeration using any available supported tool: Subfinder, Assetfinder, or Findomain
- Web directory discovery using Gobuster or Dirsearch
- Explicit URL input for web discovery
- Simple result filenames based on target and scan type
- Dependency checks, CLI help, and interactive mode
- CLI smoke tests

## Requirements

- Linux or another Unix-like environment
- Bash 4+
- Nmap for network scanning
- At least one of Subfinder, Assetfinder, or Findomain for subdomain enumeration
- At least one of Gobuster or Dirsearch for directory discovery
- A readable wordlist for directory discovery

The selected module determines which security tools are needed. `--check` reports required shell tooling and optional security utilities; it does not guarantee that every module can run.

## Installation

```bash
git clone https://github.com/bhavyasehgall/automationtools.git
cd automationtools
chmod +x automationtools.sh install_tools.sh tests/test_cli.sh
./install_tools.sh --all
./automationtools.sh --check
./automationtools.sh --help
```

`install_tools.sh` installs system dependencies on Kali Linux, Debian, and Ubuntu using APT. It attempts to install all optional tools by default and reports any packages unavailable in the configured repositories. You can install only the tools needed for a module:

```bash
./install_tools.sh --module nmap
./install_tools.sh --module subdomains
./install_tools.sh --module directory
```

`requirements.txt` is a human-readable manifest for system commands, **not a Python dependency file**. Do not run `pip install -r requirements.txt`; use `./install_tools.sh` instead. Some packages may be unavailable in a particular APT repository and may need installation from the tool's official instructions.

## Usage

### Help, version, dependencies

```bash
./automationtools.sh --help
./automationtools.sh --version
./automationtools.sh --check
```

### Nmap

```bash
# Top 100 TCP ports
./automationtools.sh -t 192.168.1.10 -m nmap --nmap-mode quick

# Service/version detection on the top 1,000 TCP ports
./automationtools.sh -t 192.168.1.10 -m nmap --nmap-mode service

# All TCP ports with service/version detection (takes longer)
./automationtools.sh -t 192.168.1.10 -m nmap --nmap-mode full
```

### Passive subdomain enumeration

```bash
./automationtools.sh -t example.com -m subdomains
```

The module runs the available supported enumerators and merges their output into a sorted, de-duplicated file. Tool failures are reported; results may be incomplete if one or more enumerators fail.

### Web directory discovery

Directory discovery requires a URL, not just a domain:

```bash
./automationtools.sh -m directory --url http://127.0.0.1:8000
```

Supply a wordlist explicitly if no supported default wordlist is installed:

```bash
./automationtools.sh -m directory \
  --url http://127.0.0.1:8000 \
  --wordlist /path/to/wordlist.txt
```

### Full workflow

The full workflow runs Nmap and, when the target is a domain, passive subdomain enumeration. Directory discovery is only included when `--url` is supplied.

```bash
./automationtools.sh -t example.com -m full --url https://example.com
```

For a local-only directory discovery test, start a local HTTP server and use its URL:

```bash
mkdir -p /tmp/automationtools-lab
echo "AutomationTools test page" > /tmp/automationtools-lab/index.html
python3 -m http.server 8000 --directory /tmp/automationtools-lab --bind 127.0.0.1
```

Then, in another terminal:

```bash
./automationtools.sh -m directory \
  --url http://127.0.0.1:8000 \
  --wordlist /path/to/small-wordlist.txt
```

### Interactive mode

```bash
./automationtools.sh --interactive
```

## Results

Reports are saved directly in `results/` (or the directory supplied with `-o`). Filenames are kept deliberately simple:

```text
results/
├── example.com_nmap.txt
├── example.com_subdomain.txt
└── example.com_directory.txt
```

The filename format is `<target>_<scan-type>.txt`, where the scan type is `nmap`, `subdomain`, or `directory`. Directory scan filenames use the URL's hostname. Re-running the same scan for the same target overwrites the existing report, keeping the output folder uncluttered. Copy or rename a report first if you want to preserve an earlier result. Avoid committing scan output; the `results/` directory is ignored by Git except for `.gitkeep`.

## Tests and static checks

Run CLI smoke tests:

```bash
bash tests/test_cli.sh
```

Run syntax checks:

```bash
bash -n automationtools.sh lib/*.sh modules/*.sh tests/*.sh
```

If ShellCheck is installed:

```bash
shellcheck automationtools.sh lib/*.sh modules/*.sh tests/*.sh
```

Tests use temporary files and validate CLI behavior and input checks. They do not replace integration testing with the actual third-party tools.

## Project structure

```text
automationtools/
├── automationtools.sh
├── lib/
│   ├── common.sh
│   ├── dependencies.sh
│   └── validation.sh
├── modules/
│   ├── nmap.sh
│   ├── subdomains.sh
│   └── directory.sh
├── tests/
│   └── test_cli.sh
├── results/
│   └── .gitkeep
├── .gitignore
├── LICENSE
└── README.md
```

## Limitations

- IPv4 and domain targets are supported; IPv6 validation is not implemented.
- Nmap modes currently scan TCP ports only.
- Subdomain enumeration depends on third-party passive data sources and can return incomplete or stale results.
- The tool does not verify that a user has authorization to scan a target.
- The dependency check is informational; availability and compatibility of each external tool should be verified before a scan.
- This is a learning and workflow-automation project, not a replacement for professional assessment, review, or established security platforms.

## Roadmap

- Add more comprehensive mocked module tests
- Add JSON summaries and structured run metadata
- Improve support for cancellation and resumable runs
- Add CI checks for syntax, ShellCheck, and tests

## License

MIT. See [`LICENSE`](LICENSE).

## Author

**Bhavya Sehgal**  
Cybersecurity · VAPT · Security Automation · Linux

GitHub: https://github.com/bhavyasehgall
