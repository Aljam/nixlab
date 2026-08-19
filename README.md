# nixlab
[![CI](https://github.com/Aljam/nixlab/actions/workflows/ci.yml/badge.svg)](https://github.com/Aljam/nixlab/actions/workflows/ci.yml) [![License](https://img.shields.io/github/license/Aljam/nixlab?label=license)](LICENSE.md) [![Nix](https://img.shields.io/badge/Nix-26.05%2B-5277C3?logo=nixos&logoColor=white)](https://nixos.org/) [![Flake](https://img.shields.io/badge/Nix-Flake-5277C3?logo=nixos&logoColor=white)](flake.nix) [![SOPS](https://img.shields.io/badge/secrets-SOPS-2F855A?logo=gnuprivacyguard&logoColor=white)](https://github.com/getsops/sops) [![Home%20Manager](https://img.shields.io/badge/Home-Manager-7EBB4B?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

A production-grade, declarative NixOS homelab infrastructure managed with flakes, SOPS-encrypted secrets, and Cachix binary caching.

## Overview

**nixlab** is a multi-server NixOS configuration repository implementing infrastructure-as-code best practices for homelab and self-hosted service deployments. The project uses Nix flakes for reproducible builds, SOPS for secret management, and Cachix for build caching across a heterogeneous hardware fleet.

## Features

- **Declarative Infrastructure**: Entire system state defined in Nix, reproducible across rebuilds
- **Multi-Host Management**: Centralized configuration for Dell R820, R730XD, R730, and custom hosts (navi, oryx)
- **Secret Management**: SOPS-encrypted secrets with per-host and shared key management
- **Binary Caching**: Cachix integration for fast, reproducible builds across all hosts
- **Role-Based Architecture**: Modular service roles (database, media, reverse-proxy, etc.) for DRY configuration
- **Hardware Abstraction**: Hardware-specific modules for server-specific kernel params, drivers, and firmware
- **CI/CD Ready**: GitHub Actions workflows for validation, secret scanning, and deployment automation
- **Security Hardening**: gitleaks integration, firewall rules via nftables, and isolated service networking

## Quick Start

### Prerequisites

```bash
# NixOS with flakes enabled
# SOPS installed
# Cachix CLI (optional but recommended)
```

### Clone and Build

```bash
git clone https://github.com/Aljam/nixlab.git
cd nixlab

# Build a specific host
nixos-rebuild switch --flake .#r730

# Or with Cachix caching
cachix use your-cache
nixos-rebuild switch --flake .#r730
```

### Add a New Host

```bash
# 1. Create host directory
mkdir -p hosts/newhost

# 2. Add configuration
cat > hosts/newhost/default.nix <<EOF
{ config, pkgs, lib, ... }: {
  imports = [
    ../common.nix
    ../../modules/roles/database
  ];
  
  networking.hostName = "newhost";
  # ... host-specific config
}
EOF

# 3. Add to flake.nix outputs
# 4. Build and deploy
nixos-rebuild switch --flake .#newhost
```

## Repository Structure

```
nixlab/
├── flake.nix              # Flake entry point: inputs, outputs, host definitions
├── flake.lock             # Locked input versions for reproducibility
├── .sops.yaml             # SOPS encryption rules and key mapping
├── CACHIX.md              # Cachix cache setup and usage guide
├── LICENSE.md             # Project license
├── .gitleaks.toml         # Secret scanning configuration
├── .github/               # GitHub Actions workflows and templates
│
├── hosts/                 # Per-host configurations
│   ├── navi/              # Custom host: navi
│   ├── oryx/              # Custom host: oryx
│   ├── r730/              # Dell PowerEdge R730
│   ├── r730xd/            # Dell PowerEdge R730XD
│   └── r820/              # Dell PowerEdge R820
│
├── modules/               # Reusable NixOS modules
│   ├── features/          # Optional features (monitoring, backup, etc.)
│   ├── hardware/          # Hardware-specific modules (Dell iDRAC, NICs, etc.)
│   └── roles/             # Service roles (database, media, proxy, etc.)
│
├── secrets/               # SOPS-encrypted secrets
│   ├── hosts/             # Host-specific secrets
│   └── shared/            # Shared secrets across hosts
│
├── users/                 # User configurations
│   └── aljam/             # User: aljam (SSH keys, home-manager, etc.)
│
├── tests/                 # NixOS tests and validation
│
└── docs/                  # Comprehensive documentation
    ├── docs-index.md      # Documentation navigation
    ├── GETTING-STARTED.md # Onboarding guide
    ├── ARCHITECTURE.md    # System architecture overview
    ├── SETUP.md           # Initial setup instructions
    ├── DEPLOYMENT-CHECKLIST.md
    ├── BACKUP-RECOVERY.md
    ├── SECRETS.md         # Secret management guide
    ├── ROLES.md           # Role definitions and usage
    ├── NETWORKING.md      # Network configuration
    └── ALERTS.md          # Alerting and monitoring
```

## Hosts

| Host    | Hardware              | Role                              | Status      |
|---------|-----------------------|-----------------------------------|-------------|
| `r820`  | Dell PowerEdge R820   | Primary compute / database        | Production  |
| `r730xd`| Dell PowerEdge R730XD | Storage / media server            | Production  |
| `r730`  | Dell PowerEdge R730   | Application server / CI runner    | Production  |
| `navi`  | Custom                | Reverse proxy / edge services     | Production  |
| `oryx`  | Custom                | Development / staging             | Development |

## Key Technologies

| Technology | Purpose |
|------------|---------|
| **NixOS** | Declarative, reproducible OS configuration |
| **Nix Flakes** | Versioned, composable Nix expressions |
| **SOPS** | Secret encryption with age/GPG keys |
| **Cachix** | Binary cache for fast Nix builds |
| **systemd** | Service orchestration and monitoring |
| **nftables** | Firewall and network security |
| **HAProxy** | Reverse proxy and load balancing |
| **PostgreSQL** | Primary database engine |
| **Docker/Podman** | Containerized service deployment |

## Documentation

Comprehensive documentation is available in the [`docs/`](docs/) directory:

- **[Getting Started](docs/GETTING-STARTED.md)** - First-time setup and onboarding
- **[Architecture](docs/ARCHITECTURE.md)** - System design and module organization
- **[Setup Guide](docs/SETUP.md)** - Initial installation and bootstrapping
- **[Secrets Management](docs/SECRETS.md)** - SOPS configuration and key rotation
- **[Roles](docs/ROLES.md)** - Service role definitions and composition
- **[Networking](docs/NETWORKING.md)** - Network topology and firewall rules
- **[Backup & Recovery](docs/BACKUP-RECOVERY.md)** - Disaster recovery procedures
- **[Deployment Checklist](docs/DEPLOYMENT-CHECKLIST.md)** - Pre-deployment validation
- **[Alerts](docs/ALERTS.md)** - Monitoring and alerting configuration
- **[Cachix Guide](CACHIX.md)** - Binary cache setup and optimization

## Common Operations

### Rebuild a Host

```bash
# Local rebuild
nixos-rebuild switch --flake .#r730

# Remote rebuild (from another machine)
nixos-rebuild switch --flake .#r730 --target-host root@r730.local
```

### Check Build Status

```bash
nix flake check
nixos-rebuild build --flake .#r730
```

### Update Inputs

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Manage Secrets

```bash
# Encrypt a new secret
sops -e secrets/shared/my-secret.yaml > secrets/shared/my-secret.enc.yaml

# Decrypt for inspection
sops -d secrets/shared/my-secret.enc.yaml
```

### Run Tests

```bash
nix build .#checks.x86_64-linux.tests
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make changes and test locally
4. Run `nix flake check` to validate
5. Commit with descriptive messages
6. Push and open a Pull Request

## Security

- All secrets are encrypted with SOPS before committing
- gitleaks scans for accidental credential exposure in CI
- Minimal host exposure via nftables firewall rules
- Regular security updates via `nix flake update`

## License

See [LICENSE.md](LICENSE.md) for details.

## Acknowledgments

- [NixOS](https://nixos.org) - The purely functional Linux distribution
- [Determinate Systems](https://determinate.systems) - Nix tooling and Cachix
- [Mozilla SOPS](https://github.com/mozilla/sops) - Secret management
- [NixOS Wiki](https://wiki.nixos.org) - Community documentation and examples

---

**Maintained by**: [@Aljam](https://github.com/Aljam)  
**Last Updated**: August 2026
