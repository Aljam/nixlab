# Architecture

This document describes the architecture and design decisions behind nixlab.

## System Overview

nixlab follows a **three-layer modular architecture** that separates concerns between hardware-specific configurations, functional roles, and reusable features.

```
┌─────────────────────────────────────────────────────────┐
│                    Host Configuration                    │
│                   (hosts/<hostname>/)                    │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Hardware    │  │    Roles     │  │    Users     │  │
│  │   Modules    │  │   Modules    │  │   Modules    │  │
│  │              │  │              │  │              │  │
│  │ • Dell R730  │  │ • desktop    │  │ • aljam      │  │
│  │ • Dell R820  │  │ • server     │  │              │  │
│  │ • System76   │  │ • media      │  │              │  │
│  │ • Desktop    │  │ • mail       │  │              │  │
│  │              │  │ • storage    │  │              │  │
│  │              │  │ • ai         │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
├─────────────────────────────────────────────────────────┤
│                   Feature Modules                        │
│              (modules/features/*.nix)                    │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │
│  │Hyprland│ │Postgres│ │Grafana │ │ ZFS    │ │Jellyfin│ │
│  │Audio   │ │Libvirt │ │Prometheus│ │Boot   │ │*arr    │ │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Design Principles

### 1. Separation of Concerns

Each layer has a specific responsibility:

- **Hardware Layer**: Physical machine characteristics (CPU, GPU, disk layout, network interfaces)
- **Role Layer**: Functional purpose (desktop, server, media, storage, etc.)
- **Feature Layer**: Reusable capabilities that can be mixed and matched
- **Host Layer**: Composition of hardware + roles + features + users

### 2. Composition Over Configuration

Instead of monolithic configurations, nixlab uses composition:

```nix
# hosts/oryx/configuration.nix
{
  imports = [
    ../../modules/roles/desktop-node.nix      # Functional role
    ../../modules/hardware/navi-desktop.nix   # Hardware specifics
    ../../users/aljam                          # User configuration
  ];
  
  networking.hostName = "oryx";                # Host-specific overrides
}
```

This approach:
- ✅ Makes it easy to understand what each machine does at a glance
- ✅ Reduces duplication across hosts
- ✅ Enables easy replication of similar machines

### 3. DRY (Don't Repeat Yourself)

Common configurations are extracted into modules:

- `modules/roles/common.nix` - Base configuration for ALL hosts
- `modules/features/*.nix` - Reusable feature modules
- `modules/hardware/*.nix` - Hardware-specific configurations reused across hosts

### 4. Declarative Everything

All system state is declared in Nix expressions:

- System packages
- Services and daemons
- User configurations
- Network settings
- File system layouts

## Module System

### Module Types

#### Hardware Modules (`modules/hardware/`)

Hardware-specific configurations that abstract physical differences:

```nix
# modules/hardware/dell-poweredge.nix
{
  imports = [
    ./modules/features/zfs-base.nix
  ];
  
  # Dell-specific hardware settings
  # IPMI configuration
  # RAID controller settings
}
```

**Available Hardware Modules**:
- `dell-poweredge.nix` - Dell PowerEdge servers (R730, R730xd, R820)
- `system76-laptop.nix` - System76 laptops
- `navi-desktop.nix` - Custom desktop builds

#### Role Modules (`modules/roles/`)

Functional roles that define what a machine does:

```nix
# modules/roles/media-node.nix
{
  imports = [
    ./common.nix
    ../features/arr-stack.nix
    ../features/jellyfin.nix
    ../features/torrents.nix
  ];
  
  # Media-specific configurations
}
```

**Available Roles**:
- `common.nix` - Base configuration (imported by all roles)
- `desktop-node.nix` - Desktop workstation
- `server-core.nix` - Minimal headless server
- `media-node.nix` - Media server
- `mail-node.nix` - Email server
- `storage-node.nix` - NAS/storage server
- `ai-node.nix` - AI/ML compute node

#### Feature Modules (`modules/features/`)

Reusable capabilities that can be combined:

```nix
# modules/features/postgres.nix
{
  services.postgresql = {
    enable = true;
    # PostgreSQL configuration
  };
}
```

**Available Features**: (23 total)
- Desktop: `hyprland`, `graphics`, `fonts`, `audio`, `bluetooth`, `gaming`, `flatpak`, `emulation`
- Media: `arr-stack`, `jellyfin`, `torrents`, `youtube`
- Infrastructure: `postgres`, `grafana`, `prometheus-server`, `node-exporter`, `reverse-proxy-backends`
- System: `boot`, `zfs-base`, `nas-mount`, `libvirt`, `remote-builder`, `nvidia-headless`, `sanoid`
- Security: `vaultwarden`
- Networking: `networking-tools`

### Module Structure

Each module follows this pattern:

```nix
{ config, lib, pkgs, ... }:

{
  # Import other modules if needed
  imports = [
    # ...
  ];
  
  # Enable services and set options
  services.someService = {
    enable = true;
    # ...
  };
  
  # System packages
  environment.systemPackages = [
    pkgs.somePackage
  ];
  
  # Custom options (optional)
  options = {
    # ...
  };
  
  # Configuration based on options
  config = {
    # ...
  };
}
```

## Dependency Graph

```
hosts/<hostname>/
  ├── roles/<role>.nix
  │     ├── common.nix
  │     │     └── features/* (base features)
  │     └── features/* (role-specific features)
  ├── hardware/<hardware>.nix
  │     └── features/* (hardware features like ZFS)
  └── users/<user>/
        └── modules/* (user-specific modules)
```

## Configuration Layers

### Layer 1: Base (common.nix)

Every host imports `modules/roles/common.nix` which provides:

- Basic system configuration
- Security settings
- Networking basics
- Nix configuration
- Common packages

### Layer 2: Role-Specific

Roles add functionality on top of common:

- `desktop-node` → GUI, desktop applications, user tools
- `server-core` → Minimal server packages, remote access
- `media-node` → Media services, storage mounts
- `ai-node` → GPU drivers, ML frameworks

### Layer 3: Hardware-Specific

Hardware modules handle physical differences:

- Bootloader configuration
- Disk layout
- GPU drivers
- Network interface names
- Power management

### Layer 4: Host-Specific

Final overrides for individual hosts:

- Hostname
- IP addresses
- Host-specific secrets
- Unique hardware quirks

## Secrets Architecture

### SOPS Integration

Secrets are managed with SOPS and GPG:

```
secrets/
├── secrets.yaml          # Encrypted secrets
└── .sops.yaml           # Encryption policies
```

### Secret Flow

```
1. Create/edit secret in secrets/secrets.yaml
2. Encrypt with SOPS (automatic on save)
3. Reference in host configuration
4. SOPS decrypts at build time
5. Secret available in NixOS configuration
```

See [Secrets Management](SECRETS.md) for details.

## Build Process

### Flake Evaluation

```
flake.nix
  ├── inputs (nixpkgs, home-manager, sops-nix, etc.)
  └── outputs
        └── nixosConfigurations
              ├── navi
              ├── oryx
              ├── r730
              ├── r730xd
              └── r820
```

### Build Command Flow

```bash
nixos-rebuild switch --flake .#navi
```

1. Flake evaluator loads `flake.nix`
2. Resolves `nixosConfigurations.navi`
3. Imports all modules from `hosts/navi/configuration.nix`
4. Evaluates Nix expressions
5. Builds system closure
6. Activates new configuration

## Design Decisions

### Why Flakes?

- **Reproducibility**: Locked inputs via `flake.lock`
- **Composability**: Easy to import other flakes
- **CLI Integration**: Built-in commands for common operations
- **Future-proof**: Official direction for Nix

### Why SOPS?

- **Git-friendly**: Encrypted files can be committed
- **Multi-key**: Multiple GPG keys can decrypt
- **NixOS Integration**: sops-nix provides seamless integration
- **Audit Trail**: Encrypted files show what secrets exist

### Why Modular Architecture?

- **Reusability**: Share configurations across hosts
- **Maintainability**: Changes in one place affect all hosts
- **Testability**: Test modules independently
- **Scalability**: Easy to add new hosts

### Why Separate Hardware/Roles?

- **Hardware Independence**: Same role works on different hardware
- **Hardware Reuse**: Same hardware config for multiple hosts
- **Clear Separation**: Easy to understand what's hardware vs function

## Security Model

### Defense in Depth

1. **Encrypted Secrets**: All sensitive data encrypted with SOPS
2. **Minimal Services**: Only necessary services enabled per role
3. **Firewall**: Enabled on all hosts with role-specific rules
4. **Regular Updates**: NixOS security updates via channels
5. **Access Control**: User-specific configurations and permissions

### Trust Boundaries

```
┌─────────────────────────────────────┐
│           Internet                  │
├─────────────────────────────────────┤
│         Firewall (nftables)         │
├─────────────────────────────────────┤
│      Reverse Proxy (optional)       │
├─────────────────────────────────────┤
│         Services                    │
│  ┌─────────┬─────────┬─────────┐   │
│  │ Jellyfin│ Postgres│ Grafana │   │
│  └─────────┴─────────┴─────────┘   │
└─────────────────────────────────────┘
```

## Performance Considerations

### Build Optimization

- **Binary Cache**: Consider Cachix for faster builds
- **Remote Builders**: `remote-builder` feature distributes builds
- **Garbage Collection**: Regular cleanup of old generations

### Runtime Optimization

- **Service Isolation**: Services run in separate systemd units
- **Resource Limits**: systemd cgroups for resource control
- **Monitoring**: Prometheus + Grafana for observability

## Future Improvements

### Planned Enhancements

1. **NixOS Tests**: Integration tests for critical services
2. **Deployment Automation**: colmena or nixops for remote deployments
3. **Monitoring Dashboards**: Pre-built Grafana dashboards
4. **Backup Automation**: borgbackup/restic integration
5. **Type Safety**: More Nix option types for better IDE support

### Scalability Considerations

As the infrastructure grows:

- Consider organizing hosts by environment (`hosts/desktops/`, `hosts/servers/`)
- Add host metadata (location, purpose, hardware)
- Implement GitOps workflow for deployments
- Add comprehensive CI/CD testing

---

**Last Updated**: August 2026
