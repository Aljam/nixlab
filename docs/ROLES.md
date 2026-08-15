# Roles Documentation

Roles define the functional purpose of each host in nixlab. Each role imports the common base and adds specific functionality.

## Role System Overview

```
modules/roles/
├── common.nix          # Base configuration (imported by all roles)
├── desktop-node.nix    # Desktop workstation
├── server-core.nix     # Minimal headless server
├── media-node.nix      # Media server
├── mail-node.nix       # Email server
├── storage-node.nix    # NAS/storage server
└── ai-node.nix         # AI/ML compute node
```

## Common Role (`common.nix`)

**Purpose**: Base configuration for ALL hosts

**What it provides**:
- Basic system configuration
- Security hardening
- Nix package manager settings
- Essential packages
- Logging and monitoring basics
- Network configuration
- Firewall rules

**When to use**: Every host imports this (directly or through another role)

---

## Desktop Node (`desktop-node.nix`)

**Purpose**: Desktop workstation with GUI

**Use for**: Personal computers, development machines, workstations

**Imports**:
- `common.nix`
- `../features/hyprland.nix` (or other DE)
- `../features/graphics.nix`
- `../features/audio.nix`
- `../features/fonts.nix`
- `../features/bluetooth.nix`

**Key features**:
- Graphical environment (Hyprland Wayland compositor)
- Desktop applications
- Audio support (PipeWire)
- Bluetooth
- Fonts and graphics drivers
- User-friendly packages

**Example usage**:
```nix
# hosts/my-desktop/configuration.nix
{
  imports = [
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/navi-desktop.nix
    ../../users/aljam
  ];
  
  networking.hostName = "my-desktop";
}
```

---

## Server Core (`server-core.nix`)

**Purpose**: Minimal headless server

**Use for**: Web servers, application servers, database servers, any headless machine

**Imports**:
- `common.nix`
- `../features/remote-builder.nix` (optional)
- `../features/node-exporter.nix` (optional)

**Key features**:
- Minimal package set
- SSH access
- No GUI
- Optimized for stability
- Remote management tools

**Example usage**:
```nix
# hosts/webserver/configuration.nix
{
  imports = [
    ../../modules/roles/server-core.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../users/aljam
  ];
  
  networking.hostName = "webserver";
  
  # Add web server features
  services.nginx.enable = true;
}
```

---

## Media Node (`media-node.nix`)

**Purpose**: Media server for home entertainment

**Use for**: Jellyfin servers, *arr stack, torrent downloads

**Imports**:
- `common.nix`
- `../features/arr-stack.nix`
- `../features/jellyfin.nix`
- `../features/torrents.nix`
- `../features/nas-mount.nix`

**Key features**:
- Jellyfin media server
- Radarr, Sonarr, etc.
- qBittorrent (torrents)
- NAS storage mounts
- Reverse proxy configuration

**Example usage**:
```nix
# hosts/media/configuration.nix
{
  imports = [
    ../../modules/roles/media-node.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../users/aljam
  ];
  
  networking.hostName = "media";
  
  # Configure storage
  fileSystems."/media/data" = {
    device = "/dev/disk/by-label/DATA";
    fsType = "ext4";
  };
}
```

---

## Mail Node (`mail-node.nix`)

**Purpose**: Self-hosted email server

**Use for**: Personal email server, small organization mail

**Imports**:
- `common.nix`
- `../features/vaultwarden.nix` (optional)
- `../features/postgres.nix` (optional)

**Key features**:
- Mail server (Postfix/Dovecot)
- Spam filtering
- Webmail interface
- SSL/TLS encryption
- Vaultwarden (password manager)

---

## Storage Node (`storage-node.nix`)

**Purpose**: NAS and file storage server

**Use for**: Network attached storage, backup server, file sharing

**Imports**:
- `common.nix`
- `../features/zfs-base.nix`
- `../features/sanoid.nix`
- `../features/nas-mount.nix`

**Key features**:
- ZFS filesystem support
- Sanoid (ZFS backup tool)
- NFS/Samba sharing
- Snapshot management
- RAID configuration

---

## AI Node (`ai-node.nix`)

**Purpose**: AI/ML compute server

**Use for**: Machine learning training, inference, GPU compute

**Imports**:
- `common.nix`
- `../features/nvidia-headless.nix` (for NVIDIA GPUs)
- `../features/libvirt.nix` (optional, for VMs)
- `../features/remote-builder.nix` (optional)

**Key features**:
- NVIDIA GPU drivers (headless)
- CUDA toolkit
- Docker/container support
- Virtualization (libvirt)
- Remote build support

---

## Choosing the Right Role

### Decision Tree

```
Is it a desktop with GUI?
├─ Yes → desktop-node
└─ No → Continue

Is it primarily for media?
├─ Yes → media-node
└─ No → Continue

Is it for email services?
├─ Yes → mail-node
└─ No → Continue

Is it primarily storage/NAS?
├─ Yes → storage-node
└─ No → Continue

Is it for AI/ML compute?
├─ Yes → ai-node
└─ No → Continue

Is it a general-purpose server?
└─ Yes → server-core
```

### Role Comparison

| Role | GUI | Media | Storage | AI/ML | Email | Use Case |
|------|-----|-------|---------|-------|-------|----------|
| `desktop-node` | ✅ | ❌ | ❌ | ❌ | ❌ | Personal computer |
| `server-core` | ❌ | ❌ | ❌ | ❌ | ❌ | General server |
| `media-node` | ❌ | ✅ | ⚠️ | ❌ | ❌ | Media server |
| `mail-node` | ❌ | ❌ | ❌ | ❌ | ✅ | Email server |
| `storage-node` | ❌ | ❌ | ✅ | ❌ | ❌ | NAS/backup |
| `ai-node` | ❌ | ❌ | ❌ | ✅ | ❌ | GPU compute |

⚠️ = Basic support, not primary focus

---

## Combining Roles

You can combine multiple roles for multi-purpose hosts:

```nix
# hosts/homelab/configuration.nix
{
  imports = [
    ../../modules/roles/server-core.nix
    ../../modules/roles/media-node.nix  # Combine roles
    ../../modules/hardware/dell-poweredge.nix
    ../../users/aljam
  ];
  
  networking.hostName = "homelab";
}
```

**Note**: Be careful of conflicts when combining roles. Test thoroughly.

---

## Best Practices

### 1. Start Minimal

Begin with `server-core` and add features as needed

### 2. Document Role Choices

Add comments explaining why you chose a role

### 3. Override Thoughtfully

Override role defaults only when necessary

### 4. Test Changes

Always test role changes on non-critical hosts first

---

## Troubleshooting Roles

### Problem: Role imports conflicting modules

**Solution**: Check for duplicate imports and remove conflicts

### Problem: Service not starting

**Solution**: Check if role enables the service correctly

### Problem: Missing packages

**Solution**: Add packages to host configuration or create custom feature module

---

## Additional Resources

- [Architecture](ARCHITECTURE.md) - Overall system design
- [Getting Started](GETTING-STARTED.md) - Setup guide
- [Features](../modules/features/) - Feature modules documentation

---

**Last Updated**: August 2026
