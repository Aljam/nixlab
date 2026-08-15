# nixlab Setup Guide

## Prerequisites

1. NixOS installed on target hardware
2. SOPS keys configured
3. pfSense router with HAProxy

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/Aljam/nixlab.git
cd nixlab
```

### 2. Configure SOPS

Edit `.sops.yaml` to add your age/pgp keys:

```yaml
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
    - age:
      - your-age-key-here
```

### 3. Add Secrets

```bash
# Edit secrets
sops secrets/secrets.yaml

# Add Grafana admin password
# Add Vaultwarden admin token
# Add PostgreSQL credentials
```

### 4. Deploy Configuration

```bash
# For r730xd server
nixos-rebuild switch --flake .#r730xd

# For other hosts
nixos-rebuild switch --flake .#navi
nixos-rebuild switch --flake .#oryx
```

### 5. Verify Deployment

```bash
# Check services
systemctl status grafana
systemctl status vaultwarden
systemctl status postgresql

# Check firewall
nft list ruleset

# Check backups
ls -la /var/backup/postgresql
```

## Adding New Hosts

1. Create `hosts/newhost/` directory
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Add to `flake.nix` outputs
4. Deploy with `nixos-rebuild switch --flake .#newhost`

## Troubleshooting

### Services not starting

```bash
# Check logs
journalctl -u grafana -f
journalctl -u vaultwarden -f
```

### Firewall blocking access

```bash
# Check firewall rules
nft list ruleset

# Temporarily disable for testing
systemctl stop nftables
```

### Backup failures

```bash
# Check backup status
systemctl status postgresql-backup.service

# View backup logs
journalctl -u postgresql-backup -f
```
