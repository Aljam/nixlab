# nixlab

![NixOS](https://img.shields.io/badge/NixOS-24.05-blue?style=for-the-badge&logo=nixos&logoColor=white)
![Flakes](https://img.shields.io/badge/Flakes-enabled-purple?style=for-the-badge&logo=nix&logoColor=white)
![SOPS](https://img.shields.io/badge/Secrets-SOPS-green?style=for-the-badge)
![Tests](https://img.shields.io/badge/Tests-NixOS-orange?style=for-the-badge)
![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus-red?style=for-the-badge&logo=prometheus&logoColor=white)

> **A modular NixOS flake configuration for managing desktops, servers, and specialized nodes with comprehensive monitoring and alerting.**

---

## Quick Start

### Build a Host

```bash
# Test configuration
nixos-rebuild build --flake .#hostname

# Deploy
nixos-rebuild switch --flake .#hostname

# Boot once (testing)
nixos-rebuild boot --flake .#hostname
```

### Add a New Host

1. Create directory: `hosts/<hostname>/`
2. Add `configuration.nix` with role imports
3. Generate hardware config: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
4. Build: `nixos-rebuild switch --flake .#<hostname>`

📖 **See**: [Getting Started Guide](docs/GETTING-STARTED.md)

---

## Features

### 🏗️ Architecture
- **Three-layer modular design**: hardware → roles → features
- **Multi-host management** from single repository
- **SOPS-encrypted secrets** with GPG
- **Home Manager integration** for user configs

### 🖥️ Desktop
- Hyprland Wayland compositor
- Gaming support (Steam, emulation)
- Flatpak support
- Audio (PipeWire), Bluetooth, Graphics

### 🖧 Infrastructure
- **PostgreSQL** database with monitoring
- **Grafana** dashboards with alerts
- **Prometheus** metrics collection
- **Node Exporter** system metrics

### 🎬 Media
- Jellyfin media server
- *arr stack (Radarr, Sonarr)
- qBittorrent torrents
- Homepage dashboard

### 🔒 Security
- SOPS secrets management
- SSH hardening (no passwords, no root)
- Firewall enabled on all hosts
- Vaultwarden password manager

### 🤖 AI/ML
- NVIDIA GPU drivers (headless)
- CUDA toolkit
- Docker support
- Libvirt virtualization

### 📊 Monitoring & Alerting
- Prometheus alerting rules
- Grafana dashboards
- Alertmanager notifications
- SSL certificate monitoring

---

## Repository Structure

```
nixlab/
├── hosts/                    # Host configurations (5 hosts)
│   ├── navi/                 # Desktop workstation
│   ├── oryx/                 # Desktop workstation
│   ├── r730/                 # Dell PowerEdge (media server)
│   ├── r730xd/               # Dell PowerEdge (storage)
│   └── r820/                 # Dell PowerEdge (AI compute)
├── modules/
│   ├── features/             # 26 feature modules
│   ├── hardware/             # 3 hardware modules
│   └── roles/                # 7 role modules
├── tests/                    # NixOS integration tests
├── secrets/                  # SOPS-encrypted secrets
├── users/                    # User configurations
├── docs/                     # Documentation (7 files)
├── .github/workflows/        # CI/CD pipelines
├── flake.nix                 # Main flake entry point
└── README.md                 # This file
```

---

## Available Roles

| Role | Description | Use For |
|------|-------------|---------|
| `common` | Base configuration | Every host imports this |
| `desktop-node` | Desktop with GUI | Personal computers |
| `server-core` | Minimal server | Headless servers |
| `media-node` | Media server | Jellyfin, *arr stack |
| `mail-node` | Email server | Self-hosted email |
| `storage-node` | NAS/Storage | File servers |
| `ai-node` | AI/ML compute | GPU workloads |

📖 **See**: [Roles Documentation](docs/ROLES.md)

---

## Hosts Inventory

| Hostname | Type | Hardware | Roles | Purpose |
|----------|------|----------|-------|---------|
| `navi` | Desktop | Custom | desktop-node | Primary workstation |
| `oryx` | Desktop | Custom | desktop-node | Secondary desktop |
| `r730` | Server | Dell R730 | server-core, media-node | Media server |
| `r730xd` | Server | Dell R730 XD | server-core, storage-node | Storage server |
| `r820` | Server | Dell R820 | server-core, ai-node | AI/ML compute |

---

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/GETTING-STARTED.md) | Setup guide for new hosts |
| [Architecture](docs/ARCHITECTURE.md) | System design and modules |
| [Roles](docs/ROLES.md) | Role system documentation |
| [Secrets](docs/SECRETS.md) | SOPS secrets management |
| [Backup & Recovery](docs/BACKUP-RECOVERY.md) | Backup strategies and DR |
| [Alerts](docs/ALERTS.md) | Monitoring alerts and runbooks |
| [Deployment Checklist](docs/DEPLOYMENT-CHECKLIST.md) | Deployment checklist |

---

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

# Show outputs
nix flake show
```

### Run Tests

```bash
# Run all tests
nix-build tests/default.nix

# Run individual test
nix-build tests/default.nix -A postgresql
```

---

## Monitoring

### Access Grafana

```bash
# Default port: 3000
http://<host>:3000
```

### Access Prometheus

```bash
# Default port: 9090
http://<host>:9090
```

### View Alerts

```bash
# Alertmanager UI
http://<host>:9093
```

📖 **See**: [Alerts Documentation](docs/ALERTS.md)

---

## Security

- ✅ All secrets encrypted with SOPS
- ✅ SSH: No password auth, no root login
- ✅ Firewall enabled on all hosts
- ✅ Regular security updates via NixOS
- ✅ Polkit for privilege management

---

## License

See [LICENSE.md](LICENSE.md)

---

## Contributing

This is a personal infrastructure repository, but feel free to:
- ⭐ Star the repo if you find it useful
- 🐛 Open issues for bugs or suggestions
- 💡 Submit PRs for improvements
- 🔀 Fork and adapt for your own use

---

**Last Updated**: August 2026  
**NixOS Version**: 24.05  
**Flake**: Enabled
