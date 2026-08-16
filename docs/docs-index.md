# nixlab documentation

This directory contains the operational, architecture, security, and contributor documentation for nixlab.

## Start here

- [Getting started](GETTING-STARTED.md) — first checkout, inspection, validation, and deployment flow.
- [Setup](SETUP.md) — environment and host preparation.
- [Architecture](ARCHITECTURE.md) — how the flake, hosts, modules, users, and secrets fit together.

## Operate safely

- [Deployment checklist](DEPLOYMENT-CHECKLIST.md) — pre- and post-deployment checks.
- [Secrets](SECRETS.md) — encrypted secret handling and rotation guidance.
- [Backup and recovery](BACKUP-RECOVERY.md) — backup validation and recovery procedures.
- [Alerts](ALERTS.md) — operational alerting guidance.
- [Testing checklist](TESTING-CHECKLIST.md) — validation before rollout.

## Understand the codebase

- [Roles](ROLES.md) — reusable system roles and composition patterns.
- [Cachix](../CACHIX.md) — binary cache configuration and usage.
- [Final status](../FINAL-STATUS.md) — project status notes.

## Repository map

- `hosts/` contains the host-specific configurations: `navi`, `oryx`, `r730`, `r730xd`, and `r820`.
- `modules/features/` contains optional feature modules.
- `modules/hardware/` contains hardware-specific modules.
- `modules/roles/` contains reusable role modules.
- `users/` contains user configuration.
- `secrets/` contains encrypted secret material.
- `tests/` contains NixOS test definitions and test documentation.

## Recommended workflow

1. Read [Getting started](GETTING-STARTED.md) and [Setup](SETUP.md).
2. Select the target host and inspect its hardware and role composition.
3. Review secret requirements without exposing plaintext values.
4. Run `nix flake check` and the applicable tests.
5. Follow the [Deployment checklist](DEPLOYMENT-CHECKLIST.md).
6. Confirm backups, monitoring, and alerts after deployment.

Documentation should describe tested repository behavior. When configuration changes, update the affected guide in the same change whenever practical.
