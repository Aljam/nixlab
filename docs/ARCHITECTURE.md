# nixlab Architecture

## Overview

nixlab is a flake-based NixOS homelab configuration. Hosts are assembled from reusable hardware, role, and feature modules. The intended workflow is to make service behavior explicit in Nix while keeping host-specific details and secrets separate.

## Configuration layers

### Flake

`flake.nix` defines inputs and produces the host configurations. Use the host output when evaluating or deploying a machine:

```bash
nix flake check
sudo nixos-rebuild test --flake .#<host>
sudo nixos-rebuild switch --flake .#<host>
```

### Hosts

`hosts/` contains machine-specific configuration. A host selects its hardware profile, roles, feature modules, networking, storage, and host settings.

Current host profiles include `navi`, `oryx`, `r730`, `r730xd`, and `r820`.

### Modules

- `modules/hardware/` contains hardware-specific settings.
- `modules/roles/` groups related capabilities into reusable system roles.
- `modules/features/` contains opt-in services and capabilities such as PostgreSQL, Grafana, Vaultwarden, media applications, monitoring, and networking tools.

A feature should expose clear options, use the standard NixOS service module where possible, and avoid embedding host-specific values unless the value is truly part of the feature.

## Current service architecture

### PostgreSQL

The PostgreSQL feature is the shared database layer. It provisions service databases and currently includes a dedicated `webscraper` database with ownership enabled for the webscraper role. Grafana is also included among the configured database consumers.

Keep database credentials in encrypted secrets. Database creation belongs in the PostgreSQL feature; application-specific connection settings belong with the consuming service or host role.

### pgAdmin

pgAdmin is configured through `services.pgadmin`. The current deployment uses:

- Initial email from the `initialEmail` option.
- Initial password from `initialPasswordFile`.
- Port `5050` from the service's `settings.port`.
- A systemd override to listen on `0.0.0.0` for remote access.
- Firewall exposure for the configured pgAdmin port.

Remote access should be restricted by network policy or placed behind an authenticated reverse proxy. The initialization password is not a long-term credential store.

### Vaultwarden

Vaultwarden uses the service module and is exposed on port `8222`. The port is handled as part of the service's current host exposure model. Do not assume that an open application port is safe for Internet exposure; use TLS, a trusted proxy boundary, and the project's secret-management process.

### Port and proxy model

Service ports are represented in host settings and included in the public backend-port collection when a service must be reachable by the reverse-proxy or host network. The reverse-proxy backend feature is optional; it provides the integration point without requiring every host to define proxy backends.

Firewall additions use the NixOS firewall integration and nftables-compatible rule content. When adding a service, update the relevant port collection and firewall policy together.

## Secrets and data

- `secrets/` contains encrypted files managed with sops-nix.
- `.sops.yaml` defines encryption rules and recipients.
- Database bootstrap credentials, pgAdmin initialization values, and Vaultwarden secrets must not be committed in plaintext.
- Persistent application data should be covered by the backup and recovery procedure.

## Design principles

1. Prefer declarative NixOS service options over ad-hoc systemd units.
2. Keep host-specific values in settings or host configuration.
3. Use feature modules for reusable service behavior.
4. Keep secrets encrypted and reference files rather than inline values.
5. Treat firewall and proxy exposure as part of the service design.
6. Validate changes with `nix flake check` and a host-specific rebuild test.

## Adding a feature

1. Add a focused module under `modules/features/`.
2. Define options for values that vary by host, such as ports, paths, and enablement.
3. Add required databases to the PostgreSQL feature only when the service needs them.
4. Add required firewall or public backend ports in the same change.
5. Wire the feature into the appropriate role or host.
6. Update the README and deployment documentation when the feature changes operator-visible behavior.
7. Run checks before deployment.
