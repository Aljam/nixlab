# nixlab

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-5277C3?logo=nixos&logoColor=white)](https://wiki.nixos.org/wiki/Flakes)
[![License](https://img.shields.io/github/license/Aljam/nixlab)](LICENSE.md)
[![Last Commit](https://img.shields.io/github/last-commit/Aljam/nixlab)](https://github.com/Aljam/nixlab/commits/main/)

A declarative NixOS homelab built from reusable modules, encrypted secrets, and reproducible host configurations.

nixlab is the configuration repository for a multi-host homelab. It turns servers, services, networking, storage, monitoring, and user environments into version-controlled Nix code that can be reviewed, tested, and deployed consistently.

## Why nixlab

- **Declarative infrastructure:** System behavior is described in Nix instead of assembled manually on each machine.
- **Reusable composition:** Hardware modules, roles, and feature modules can be combined for different hosts.
- **Reproducible deployments:** Flakes pin inputs and provide explicit host configuration outputs.
- **Secure by default:** Credentials and sensitive configuration are managed with sops-nix rather than stored as plaintext.
- **Operationally documented:** Deployment, backup, secrets, alerts, and architecture guidance live alongside the code.

## Architecture at a glance

The repository is organized into layers:

```text
flake.nix
├── hosts/                 Host-specific configuration
├── modules/hardware/      Hardware profiles and machine integration
├── modules/roles/         Reusable system compositions
├── modules/features/      Opt-in services and capabilities
├── users/                 User and Home Manager configuration
├── secrets/               Encrypted sops-nix data
├── tests/                 Configuration and evaluation tests
└── docs/                  Architecture and operations documentation
```

Hosts select the hardware, roles, and features they need. Shared values such as `DEFAULT_SERVER`, service ports, and public backend ports are kept in host settings so modules remain reusable and operator-visible behavior stays centralized.

## Hosts

The current host profiles are:

| Host | Intended role |
| --- | --- |
| `navi` | General-purpose host profile. |
| `oryx` | Host profile for additional homelab workloads. |
| `r730` | Dell PowerEdge R730 profile. |
| `r730xd` | Dell PowerEdge R730xd profile. |
| `r820` | Dell PowerEdge R820 profile. |

Host-specific hardware and deployment details should be confirmed in the corresponding directory before applying a configuration.

## Services and capabilities

Feature modules currently cover infrastructure, databases, monitoring, media, networking, desktop, and security-related workloads. Notable services include:

- PostgreSQL, including Grafana database support.
- pgAdmin, configured through the NixOS service module on port `5050`.
- Vaultwarden on port `8222`.
- Grafana, Prometheus, node exporter, and alerting components.
- Jellyfin and the Arr ecosystem, including Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, and related tools.
- Audiobookshelf, Seerr, Shoko, Autobrr, Recyclarr, torrents, and YouTube-related tooling.
- ZFS, Sanoid, NAS mounts, remote builders, reverse-proxy integration, networking tools, and hardware acceleration.

Service exposure is deliberate: ports, firewall rules, and optional reverse-proxy backends must remain aligned. A service being enabled does not by itself mean it should be reachable from the public Internet.

## Quick start

### Prerequisites

Install Nix with flakes enabled and ensure you have access to the target host and the repository's encrypted secret keys. Review the secret-management guide before attempting a deployment.

### Check the flake

```bash
nix flake check
```

### Test a host

Replace `<host>` with one of the configured host names:

```bash
sudo nixos-rebuild test --flake .#<host>
```

This activates the configuration temporarily so services and hardware changes can be verified without making the generation the default boot configuration.

### Apply a host configuration

After testing and reviewing service status, apply the configuration persistently:

```bash
sudo nixos-rebuild switch --flake .#<host>
```

For a production-style rollout, follow [docs/DEPLOYMENT-CHECKLIST.md](docs/DEPLOYMENT-CHECKLIST.md).

## Repository layout

| Path | Description |
| --- | --- |
| `flake.nix` | Flake inputs and NixOS configuration outputs. |
| `flake.lock` | Locked input revisions for reproducible evaluation. |
| `hosts/` | Machine-specific configuration for each host. |
| `modules/hardware/` | Hardware and platform integration. |
| `modules/roles/` | Higher-level combinations of features. |
| `modules/features/` | Individual services and reusable capabilities. |
| `users/` | User accounts and Home Manager configuration. |
| `secrets/` | Encrypted secrets managed with sops-nix. |
| `tests/` | Configuration and evaluation tests. |
| `docs/` | Operational and architectural documentation. |
| `.sops.yaml` | sops-nix encryption rules and recipients. |

## Documentation

- [Getting started](docs/GETTING-STARTED.md) — Initial setup and first deployment.
- [Architecture](docs/ARCHITECTURE.md) — Configuration layers, service design, ports, and proxy behavior.
- [Deployment checklist](docs/DEPLOYMENT-CHECKLIST.md) — Preflight, validation, rollout, and post-deployment checks.
- [Secrets](docs/SECRETS.md) — Encrypted secret layout and safe editing.
- [Backup and recovery](docs/BACKUP-RECOVERY.md) — Data protection and restoration procedures.
- [Alerts](docs/ALERTS.md) — Monitoring and alerting guidance.
- [Roles](docs/ROLES.md) — Role composition and responsibilities.
- [Cachix](CACHIX.md) — Binary-cache setup and troubleshooting.
- [Complete documentation index](docs/docs-index.md) — Full documentation map.

## Security and operations

- Never commit decrypted secrets, passwords, private keys, tokens, or generated credentials.
- Keep bootstrap credentials in encrypted secret files and rotate them after first use.
- Treat pgAdmin on port `5050` and Vaultwarden on port `8222` as trusted-network services unless they are protected by an appropriately configured TLS reverse proxy.
- Include persistent service data and databases in backup planning.
- Review firewall and public backend port changes as part of every service change.
- Validate configurations before switching generations, and record the deployed revision for operational traceability.

## Contributing

Keep changes focused and composable:

1. Add or update a feature under `modules/features/`.
2. Put host-specific values in host settings rather than hard-coding them in reusable modules.
3. Update roles or host imports as needed.
4. Update operator-facing documentation when ports, databases, secrets, or access behavior changes.
5. Run `nix flake check` and a host-specific test activation before deployment.

See [LICENSE.md](LICENSE.md) for licensing information.