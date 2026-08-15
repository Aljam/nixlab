# nixlab Architecture

## Overview

nixlab is a flake-based NixOS homelab configuration. It models hosts, hardware, roles, services, networking, storage, monitoring, users, and secrets as reviewable code.

The configuration is deliberately layered: machine-specific details live with hosts, reusable behavior lives in modules, and sensitive values stay encrypted. This keeps deployments reproducible without forcing every host to run the same workload.

## Configuration layers

### Flake

`flake.nix` defines the inputs and produces the NixOS configuration outputs. `flake.lock` pins input revisions so evaluations are reproducible.

Common commands are:

```bash
nix flake check
sudo nixos-rebuild test --flake .#<host>
sudo nixos-rebuild switch --flake .#<host>
```

### Hosts

`hosts/` contains machine-specific configuration. A host selects its hardware profile, roles, feature modules, networking, storage, and host settings.

Current host profiles include:

- `navi`
- `oryx`
- `r730`
- `r730xd`
- `r820`

Review the target host directory before deploying; hardware assumptions and enabled workloads are host-specific.

### Modules

- `modules/hardware/` contains hardware and platform integration.
- `modules/roles/` groups related capabilities into reusable system compositions.
- `modules/features/` contains opt-in services and capabilities.

Feature modules should expose clear options, use standard NixOS service modules where possible, and avoid embedding values that belong in host settings.

### Users and secrets

- `users/` contains user and Home Manager configuration.
- `secrets/` contains encrypted sops-nix data.
- `.sops.yaml` defines encryption rules and recipients.

Secrets should be referenced through files or module options, never copied into plaintext configuration or committed directly.

## Service architecture

### PostgreSQL

PostgreSQL provides the shared database layer for configured applications, including Grafana. Database declarations belong in the PostgreSQL feature, while application-specific connection settings belong with the consuming service or host role.

Persistent database storage must be included in the backup plan. Credentials and bootstrap values must remain encrypted.

### pgAdmin

pgAdmin is configured through the NixOS `services.pgadmin` module. The current deployment uses:

- `initialEmail` for the initial administrator address.
- `initialPasswordFile` for the bootstrap password.
- `settings.port` with port `5050`.
- A systemd override to listen on `0.0.0.0` when remote access is required.
- Firewall exposure for the configured pgAdmin port.

Remote access should be limited by network policy or placed behind an authenticated TLS reverse proxy. Change the bootstrap password after first login.

### Vaultwarden

Vaultwarden is exposed on port `8222`. Its feature module manages service configuration and host exposure. Use TLS, a trusted proxy boundary, and the repository's secret-management process before making it available outside the trusted network.

### Monitoring and media

The feature set includes Grafana, Prometheus, node exporter, alerting, Jellyfin, the Arr applications, Audiobookshelf, Seerr, Shoko, Autobrr, Recyclarr, torrents, and related tooling. Enable workloads through the appropriate role or host rather than adding ad-hoc service configuration to a machine.

## Ports, firewall, and proxy

Service exposure is part of the architecture, not an afterthought.

- Shared values such as `DEFAULT_SERVER` come from host settings.
- Service ports are kept in settings or feature configuration rather than scattered literals.
- Public service ports are collected into the host's backend-port configuration when needed.
- Firewall additions use the NixOS firewall integration and nftables-compatible rule content.
- Reverse-proxy backends are optional and should be defined only for services that need proxy exposure.

When adding or changing a service, update its port, firewall policy, public backend exposure, proxy configuration, and documentation together. An enabled service is not automatically safe for public Internet exposure.

## Data and recovery

Persistent application data, PostgreSQL data, encrypted secrets, and host-specific state require explicit backup decisions. See [Backup and Recovery](BACKUP-RECOVERY.md) for the recovery process and [Secrets](SECRETS.md) for encrypted values.

## Design principles

1. Prefer declarative NixOS service options over ad-hoc systemd units.
2. Keep host-specific values in settings or host configuration.
3. Use feature modules for reusable service behavior.
4. Keep secrets encrypted and reference files rather than inline values.
5. Treat firewall and proxy exposure as part of service design.
6. Include persistent data in backup and recovery planning.
7. Validate changes with `nix flake check` and a host-specific rebuild test.

## Adding or changing a feature

1. Add or update a focused module under `modules/features/`.
2. Define options for values that vary by host, such as ports, paths, and enablement.
3. Add the feature to the appropriate role or host.
4. Add required firewall and public backend ports in the same change.
5. Add or update secrets using the encrypted workflow.
6. Update the README and operational documentation when behavior changes.
7. Run checks before deployment and record the deployed revision.
