# Documentation Index

This index is the starting point for operating and extending nixlab.

## Start here

- [README](../README.md) — Project overview, architecture, services, quick start, and operational guidance.
- [Getting Started](GETTING-STARTED.md) — Initial setup and first deployment.
- [Setup](SETUP.md) — Short setup reference.

## Architecture and development

- [Architecture](ARCHITECTURE.md) — Flake, host, role, feature, service, port, firewall, proxy, data, and secret design.
- [Roles](ROLES.md) — Role composition and responsibilities.

## Operations

- [Deployment Checklist](DEPLOYMENT-CHECKLIST.md) — Preflight, validation, service checks, rollout, and post-deployment verification.
- [Alerts](ALERTS.md) — Monitoring and alerting guidance.
- [Backup and Recovery](BACKUP-RECOVERY.md) — Backup scope and recovery procedures.
- [Cachix](../CACHIX.md) — Binary-cache setup and troubleshooting.

## Security

- [Secrets](SECRETS.md) — sops-nix layout, editing encrypted values, and safe secret handling.

## Current operator notes

The current configuration includes PostgreSQL-backed services, pgAdmin on port `5050`, and Vaultwarden on port `8222`. pgAdmin uses the NixOS service options for its initial email, password file, and port, with a systemd listen override for remote access. Shared values such as `DEFAULT_SERVER` are sourced from host settings, and service ports must stay aligned with firewall and public-backend configuration.

Service exposure should be reviewed as a complete path: service configuration, listening address, firewall rules, public backend ports, reverse-proxy routes, TLS, and authentication. Do not infer Internet safety from service enablement alone.

## Documentation maintenance

When adding or changing a feature:

1. Update the relevant feature, role, or architecture documentation.
2. Add operator-visible ports, databases, credentials, and access requirements to the deployment checklist.
3. Update the README when the change affects repository users or deployment behavior.
4. Review backups, monitoring, and alerting for new persistent or critical services.
5. Run `nix flake check` and validate links and commands before committing.
