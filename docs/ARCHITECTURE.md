# Architecture

This document describes the system architecture, module organization, and design principles of the nixlab infrastructure.

## System Overview

nixlab follows a **layered, role-based architecture** that separates concerns across hardware abstraction, service roles, and optional features. This design enables DRY (Don't Repeat Yourself) configuration while maintaining flexibility for host-specific customizations.

```
┌─────────────────────────────────────────────────────────┐
│                    Host Configuration                    │
│              (hosts/{navi,oryx,r730,r820})               │
├─────────────────────────────────────────────────────────┤
│                      User Configuration                   │
│                    (users/{aljam,...})                    │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   Roles     │  │  Features   │  │    Hardware     │  │
│  │  (modules)  │  │  (modules)  │  │    (modules)    │  │
│  │             │  │             │  │                 │  │
│  │ - database  │  │ - monitoring│  │ - dell-r820     │  │
│  │ - media     │  │ - backup    │  │ - dell-r730     │  │
│  │ - proxy     │  │ - logging   │  │ - custom        │  │
│  │ - app       │  │ - alerting  │  │                 │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    NixOS Base System                     │
│              (nixpkgs, nixos-hardware, etc.)             │
└─────────────────────────────────────────────────────────┘
```

## Flake Structure

### Inputs

```nix
# flake.nix
inputs = {
  nixpkgs;          # Nix package collection
  nixos-hardware;   # Hardware-specific configurations
  sops-nix;         # SOPS integration for NixOS
  home-manager;     # User environment management
  agenix;           # Alternative secret management (optional)
};
```

### Outputs

```nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations = {
    r820 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/r820
        ./users/aljam
        # ... other modules
      ];
    };
    # ... other hosts
  };
  
  checks = {
    tests = import ./tests;
  };
};
```

## Module Organization

### `modules/roles/`

Service roles define **what a host does**. Each role is a self-contained NixOS module that can be composed into host configurations.

```
modules/roles/
├── database/          # PostgreSQL, MariaDB, Redis
├── media/             # Jellyfin, Sonarr, Radarr, Lidarr
├── proxy/             # HAProxy, Nginx, Traefik
├── app/               # Application server (Node.js, Python, etc.)
├── storage/           # NFS, Samba, ZFS management
├── monitoring/        # Prometheus, Grafana, Node Exporter
└── ci/                # GitHub Actions runners, CI infrastructure
```

### `modules/features/`

Features are **optional capabilities** that can be added to any host, independent of roles.

```
modules/features/
├── backup/            # rsync, restic, borgbackup
├── logging/           # journald, rsyslog, loki
├── alerting/          # systemd alerts, email notifications
├── hardening/         # Security hardening (fail2ban, auditd)
└── virtualization/    # Docker, Podman, libvirt
```

### `modules/hardware/`

Hardware modules provide **vendor-specific configurations** for supported server platforms.

```
modules/hardware/
├── dell-r820/         # Dell PowerEdge R820 specifics
├── dell-r730/         # Dell PowerEdge R730 specifics
├── dell-r730xd/       # Dell PowerEdge R730XD specifics
└── custom/            # Generic x86_64 hardware
```

## Configuration Layers

### Layer 1: NixOS Base

The foundation is vanilla NixOS from `nixpkgs`, providing:
- System packages and services
- Kernel and bootloader
- User management
- Network configuration

### Layer 2: Hardware Abstraction

Hardware modules customize the base for specific platforms.

### Layer 3: Roles and Features

Roles and features compose into functional service definitions.

### Layer 4: Host Configuration

Host configurations tie everything together with site-specific settings.

### Layer 5: User Configuration

User modules define SSH keys, home-manager configurations, and development environments.

## Design Principles

### 1. Declarative Over Imperative

All system state is defined in Nix expressions. No manual configuration outside the repository.

### 2. Composition Over Inheritance

Modules compose via imports rather than deep inheritance hierarchies.

### 3. Separation of Concerns

- Hardware modules know nothing about services
- Roles are independent of specific hosts
- Secrets are isolated from configuration logic

### 4. Reproducibility

Every build is reproducible from `flake.lock`. No floating versions.

### 5. Security by Default

- All secrets encrypted before commit
- Minimal service exposure via firewall
- Regular security updates via flake updates

---

**Last Updated**: August 2026