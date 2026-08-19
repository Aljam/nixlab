# nixlab

[![CI](https://github.com/Aljam/nixlab/actions/workflows/ci.yml/badge.svg)](https://github.com/Aljam/nixlab/actions/workflows/ci.yml) [![License](https://img.shields.io/github/license/Aljam/nixlab?label=license)](LICENSE.md) [![Nix](https://img.shields.io/badge/Nix-26.058%2B-5277C3?logo=nixos&logoColor=white)](https://nixos.org/) [![Flake](https://img.shields.io/badge/Nix-Flake-5277C3?logo=nixos&logoColor=white)](flake.nix) [![SOPS](https://img.shields.io/badge/secrets-SOPS-2F855A?logo=gnuprivacyguard&logoColor=white)](https://github.com/getsops/sops) [![Home%20Manager](https://img.shields.io/badge/Home-Manager-7EBB4B?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

Declarative NixOS infrastructure for a homelab.

## Overview

This repository manages multiple NixOS hosts from a shared flake. Configuration is organized around reusable feature, hardware, and role modules so host definitions stay focused on hardware and deployment-specific choices.

## Repository layout

- `flake.nix` and `flake.lock` — flake inputs and reproducible outputs.
- `hosts/` — host-specific configurations for `navi`, `oryx`, `r730`, `r730xd`, and `r820`.
- `modules/features/` — optional capabilities and services.
- `modules/hardware/` — hardware- and platform-specific settings.
- `modules/roles/` — composable system roles.
- `users/` — user and home configuration.
- `secrets/` — encrypted secret material; never commit plaintext secrets.
- `tests/` — NixOS tests covering backup, firewall, security, and services.
- `docs/` — operational, networking, and contributor documentation.

## Quick start

Clone the repository and enter it:

```sh
git clone https://github.com/Aljam/nixlab.git
cd nixlab
```

Inspect available flake outputs before deploying:

```sh
nix flake show
nix flake check
```

Build a host configuration without changing the running system:

```sh
sudo nixos-rebuild build --flake .#<host>
```

Apply a host configuration:

```sh
sudo nixos-rebuild switch --flake .#<host>
```

Replace `<host>` with the intended host name and review the generated diff before switching. For first-time setup, secrets, deployment checks, and recovery procedures, start with [`docs/docs-index.md`](docs/docs-index.md).

## Validation

Run the repository checks before deployment:

```sh
nix flake check
```

The NixOS test definitions are in `tests/`. They cover backup behavior, firewall rules, security expectations, and services. Follow the deployment and validation guidance in [`docs/DEPLOYMENT-CHECKLIST.md`](docs/DEPLOYMENT-CHECKLIST.md), and inspect [`tests/`](tests/) for the available test definitions.

## Secrets

Secrets are managed as encrypted files. Do not place credentials, private keys, tokens, or generated plaintext secret files in commits. Read [`docs/SECRETS.md`](docs/SECRETS.md) before editing secret references or provisioning a host.

## Documentation

- [Documentation index](docs/docs-index.md)
- [Getting started](docs/GETTING-STARTED.md)
- [Setup](docs/SETUP.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Roles and modules](docs/ROLES.md)
- [Secrets](docs/SECRETS.md)
- [Networking](docs/NETWORKING.md)
- [Deployment checklist](docs/DEPLOYMENT-CHECKLIST.md)
- [Backup and recovery](docs/BACKUP-RECOVERY.md)
- [Alerts](docs/ALERTS.md)
- [Cachix](CACHIX.md)

## Contributing

Keep changes small and composable. Prefer reusable modules over host-specific duplication, validate changes with `nix flake check`, and update the relevant documentation when workflows or interfaces change.

## License

See [`LICENSE.md`](LICENSE.md).
