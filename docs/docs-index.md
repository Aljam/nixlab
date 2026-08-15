# Documentation Index

This index is the starting point for operating and extending nixlab.

## Start here

- [README](../README.md) — Project overview, repository layout, current service notes, and quick validation commands.
- [Getting Started](GETTING-STARTED.md) — Initial setup and first deployment.
- [Setup](SETUP.md) — Short setup reference.

## Architecture and development

- [Architecture](ARCHITECTURE.md) — Flake, host, role, and feature-module structure; current PostgreSQL, pgAdmin, Vaultwarden, port, and proxy behavior.
- [Roles](ROLES.md) — Role composition and responsibilities.

## Operations

- [Deployment Checklist](DEPLOYMENT-CHECKLIST.md) — Preflight, validation, service-specific checks, rollout, and post-deployment verification.
- [Alerts](ALERTS.md) — Monitoring and alerting guidance.
- [Backup and Recovery](BACKUP-RECOVERY.md) — Backup scope and recovery procedures.
- [Cachix](../CACHIX.md) — Binary-cache setup and troubleshooting.

## Security

- [Secrets](SECRETS.md) — sops-nix layout, editing encrypted values, and safe secret handling.

## Current operator notes

The current configuration includes a PostgreSQL database for the webscraper workload, pgAdmin on port `5050`, and Vaultwarden on port `8222`. pgAdmin uses the NixOS service options for its initial email, password file, and port, with a systemd listen override for remote access. Shared values such as `DEFAULT_SERVER` are sourced from host settings, and service ports must stay aligned with firewall and public-backend configuration.

When a recent commit changes a service, port, database, firewall rule, or secret input, update the README, architecture guide, and deployment checklist together so operator-facing documentation remains consistent.

## Documentation maintenance

When adding or changing a feature:

1. Update the relevant feature or role documentation.
2. Add operator-visible ports, databases, credentials, and access requirements to the deployment checklist.
3. Update the README when the change affects repository users or deployment behavior.
4. Run `nix flake check` and validate links and commands before committing.
