# nixlab

A modular NixOS flake configuration for managing multiple hosts including desktops, servers, and specialized nodes.

## Overview

This repository contains my complete NixOS infrastructure configuration using flakes, SOPS for secrets management, and a modular architecture that separates hardware, roles, and features.

### Key Features

- **Modular Design**: Three-layer architecture (hardware → roles → features)
- **Multi-host Management**: Manage desktops, servers, and specialized nodes from one repository
- **Secrets Management**: SOPS-encrypted secrets with GPG
- **CI/CD**: Automated testing and build verification
- **Home Manager Integration**: User configurations with Home Manager

## Quick Start

### Prerequisites

```bash
# NixOS with flakes enabled
# SOPS for secrets management
# GPG for encryption
```

### Building a Host

```bash
# Test a configuration (recommended first)
nixos-rebuild build --flake .#hostname

# Switch to a new configuration
nixos-rebuild switch --flake .#hostname

# Boot into a configuration once (for testing)
nixos-rebuild boot --flake .#hostname
```

### Adding a New Host

1. Create directory: `hosts/<hostname>/`
2. Add `configuration.nix` importing desired roles and hardware modules
3. Generate hardware config: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
4. Add secrets if needed (see [Secrets Management](docs/SECRETS.md))
5. Build: `nixos-rebuild switch --flake .#<hostname>`

See [Getting Started Guide](docs/GETTING-STARTED.md) for detailed instructions.

## Repository Structure

```
nixlab/
├── hosts/                    # Host-specific configurations
│   ├── navi/                 # Desktop machine
│   ├── oryx/                 # Desktop machine
│   ├── r730/                 # Dell PowerEdge server
│   ├── r730xd/               # Dell PowerEdge server
│   └── r820/                 # Dell PowerEdge server
├── modules/
│   ├── features/             # Feature modules (23 modules)
│   ├── hardware/             # Hardware-specific configurations
│   └── roles/                # Role-based configurations (7 roles)
├── secrets/                  # SOPS-encrypted secrets
├── users/
│   └── aljam/                # User configuration
├── docs/                     # Documentation
├── .github/workflows/        # CI/CD pipelines
├── flake.nix                 # Main flake entry point
└── README.md                 # This file
```

## Available Roles

| Role | Description | Use For |
|------|-------------|---------||
| `common` | Base configuration for all nodes | Every host imports this |
| `desktop-node` | Desktop workstation setup | Personal computers with GUI |
| `server-core` | Minimal server configuration | Headless servers |
| `media-node` | Media server (Jellyfin, *arr stack) | Home media servers |
| `mail-node` | Email server | Self-hosted email |
| `storage-node` | Storage/NAS configuration | File servers |
| `ai-node` | AI/ML compute node | GPU compute servers |

See [Roles Documentation](docs/ROLES.md) for details.

## Available Features

### Desktop & GUI
- `hyprland` - Wayland compositor
- `graphics` - GPU drivers and display
- `fonts` - Font configuration
- `audio` - PulseAudio/PipeWire
- `bluetooth` - Bluetooth support
- `gaming` - Gaming tools (Steam, etc.)
- `flatpak` - Flatpak support
- `emulation` - Emulation tools

### Media & Entertainment
- `arr-stack` - Radarr, Sonarr, etc.
- `jellyfin` - Media server
- `torrents` - Torrent client (qBittorrent)
- `youtube` - YouTube download tools

### Infrastructure
- `postgres` - PostgreSQL database
- `grafana` - Monitoring dashboards
- `prometheus-server` - Metrics collection
- `node-exporter` - System metrics
- `reverse-proxy-backends` - Reverse proxy configuration

### System & Hardware
- `boot` - Bootloader configuration
- `zfs-base` - ZFS filesystem support
- `nas-mount` - Network storage mounts
- `libvirt` - Virtualization
- `remote-builder` - Distributed builds
- `nvidia-headless` - NVIDIA GPU compute
- `sanoid` - ZFS backup tool

### Security
- `vaultwarden` - Password manager

See individual feature modules in `modules/features/` for configuration options.

## Documentation

- **[Getting Started](docs/GETTING-STARTED.md)** - Detailed setup guide
- **[Architecture](docs/ARCHITECTURE.md)** - System design and modules
- **[Roles](docs/ROLES.md)** - Role system documentation
- **[Secrets Management](docs/SECRETS.md)** - SOPS workflow
- **[Backup & Recovery](docs/BACKUP-RECOVERY.md)** - Disaster recovery

## Common Operations

### Update Flake Inputs

```bash
nix flake update
```

### Garbage Collection

```bash
# Remove old generations
nix-collect-garbage --delete-older-than 7d

# Remove unused packages
nix-store --gc
```

### Check Configuration

```bash
# Verify flake
nix flake check

# Show available outputs
nix flake show
```

## Hosts Inventory

| Hostname | Type | Hardware | Roles | Purpose |
|----------|------|----------|-------|---------||
| `navi` | Desktop | Custom | desktop-node | Primary workstation |
| `oryx` | Desktop | Custom | desktop-node | Secondary desktop |
| `r730` | Server | Dell PowerEdge R730 | server-core, media-node | Media server |
| `r730xd` | Server | Dell PowerEdge R730 XD | server-core, storage-node | Storage server |
| `r820` | Server | Dell PowerEdge R820 | server-core, ai-node | AI/ML compute |

## Security Notes

- All secrets are encrypted with SOPS
- GPG keys required for decryption
- Firewall enabled on all hosts
- Regular security updates via NixOS channels

## License

See [LICENSE.md](LICENSE.md)

## Contributing

This is a personal infrastructure repository, but feel free to:
- Open issues for bugs or suggestions
- Submit PRs for improvements
- Fork and adapt for your own use

---

**Last Updated**: August 2026
