# nixlab

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-5277C3?logo=nixos&logoColor=white)](https://wiki.nixos.org/wiki/Flakes)
[![License](https://img.shields.io/github/license/Aljam/nixlab)](LICENSE.md)
[![Last Commit](https://img.shields.io/github/last-commit/Aljam/nixlab)](https://github.com/Aljam/nixlab/commits/main/)

Declarative NixOS homelab configuration managed with flakes.

## What this repository provides

- Reproducible NixOS configurations for the homelab hosts.
- Reusable feature modules for infrastructure, monitoring, media services, and desktop functionality.
- Role-based composition for keeping host configuration small and auditable.
- Secret management with sops-nix.
- PostgreSQL-backed services, including Grafana and the webscraper database.
- Optional Vaultwarden and pgAdmin services with explicit service ports.
- Firewall and reverse-proxy integration for services exposed by a host.

## Repository layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Flake inputs and NixOS configuration outputs. |
| `hosts/` | Host-specific hardware and system configuration. |
| `modules/features/` | Opt-in service and capability modules. |
| `modules/roles/` | Higher-level compositions of features. |
| `modules/hardware/` | Hardware-specific configuration. |
| `users/` | User and Home Manager configuration. |
| `secrets/` | Encrypted secrets; never commit plaintext credentials. |
| `tests/` | Evaluation and configuration tests. |
| `docs/` | Operational, architecture, deployment, backup, and secret-management guides. |

## Current service notes

### PostgreSQL and webscraper

The PostgreSQL feature provisions the databases required by the homelab. The current configuration includes a dedicated `webscraper` database with database ownership enabled. PostgreSQL remains the backend for Grafana and other configured services.

### pgAdmin

The pgAdmin service is configured through the NixOS `services.pgadmin` module. Its initial email and password are supplied through the module's initialization options, and the service listens on port `5050`. The firewall allows the configured pgAdmin port, and a systemd override makes pgAdmin listen on `0.0.0.0` when remote access is required.

Treat the initial password as a bootstrap credential: keep it in encrypted secret material and change it after first login.

### Vaultwarden

Vaultwarden is exposed on port `8222`. Its service configuration and firewall exposure are managed by the feature module; verify the host's network boundary and reverse-proxy policy before exposing it beyond the trusted network.

### Service settings and firewall ports

Service defaults are centralized in host settings. In particular, `DEFAULT_SERVER` is read from settings rather than being hard-coded in individual modules. Public service ports are collected into the host's backend-port configuration, while custom firewall rules use the NixOS firewall integration and nftables syntax.

## Getting started

1. Review [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).
2. Inspect [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) before adding a feature or host.
3. Configure secrets according to [docs/SECRETS.md](docs/SECRETS.md).
4. Validate a configuration with:

   ```bash
   nix flake check
   sudo nixos-rebuild test --flake .#<host>
   ```

5. Use [docs/DEPLOYMENT-CHECKLIST.md](docs/DEPLOYMENT-CHECKLIST.md) for a rollout.

## Documentation

Start at [docs/docs-index.md](docs/docs-index.md) for the complete documentation map. The repository also includes [CACHIX.md](CACHIX.md) for binary-cache setup.

## Safety

This repository contains encrypted secret files and infrastructure configuration. Do not commit decrypted secrets, generated credentials, private keys, or machine-specific sensitive data.