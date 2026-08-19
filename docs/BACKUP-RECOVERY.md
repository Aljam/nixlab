# Backup & Recovery

This document outlines backup strategies, disaster recovery procedures, and business continuity planning for nixlab infrastructure.

## Backup Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Production     │     │  Backup Agent    │     │  Backup Storage │
│  Hosts          │────▶│  (restic/borg)   │────▶│  (local/remote) │
│  (r820, r730)   │     │  (scheduled)     │     │  (tank/offsite) │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Backup Strategy

### 3-2-1 Rule

- **3 copies** of data (production + 2 backups)
- **2 different media** (local disk + offsite)
- **1 offsite copy** (remote location or cloud)

### Backup Tiers

| Tier | Data Type              | Frequency | Retention | Method      |
|------|------------------------|-----------|-----------|-------------|
| 1    | NixOS configuration    | Every commit | Indefinite | Git (GitHub) |
| 2    | Database (PostgreSQL)  | Hourly    | 7 days    | pg_dump + restic |
| 3    | Media files            | Daily     | 30 days   | restic + hardlinks |
| 4    | User home directories  | Daily     | 14 days   | restic |
| 5    | Secrets (SOPS keys)    | On change | Indefinite | Encrypted backup |

## Backup Tools

### restic

**Primary backup tool** for file-level backups with deduplication and encryption.

```nix
# modules/features/backup/default.nix
{
  services.restic.backups = {
    daily = {
      enable = true;
      paths = [ "/home" "/var/lib/postgresql" "/srv/media" ];
      repository = "/mnt/backup/restic";
      passwordFile = "/run/secrets/restic-password";
      timerConfig.OnCalendar = "daily";
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
    };
  };
}
```

### PostgreSQL Backup

```nix
# modules/roles/database/default.nix
{
  services.postgresql = {
    enable = true;
    backup = {
      enable = true;
      compression = "gzip";
      directory = "/var/backup/postgresql";
    };
  };
  
  systemd.services.pg-backup = {
    enable = true;
    startAt = "hourly";
    serviceConfig.ExecStart = "''
      #!/bin/sh
      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      pg_dumpall | gzip > /var/backup/postgresql/full-$TIMESTAMP.sql.gz
    ''";
  };
}
```

### ZFS Snapshots

```nix
# modules/roles/storage/default.nix
{
  services.zfs = {
    autoSnapshot = {
      enable = true;
      frequent = 4;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };
  };
}
```

## Recovery Procedures

### Scenario 1: Single File Recovery

```bash
# 1. List available snapshots
sudo restic -r /mnt/backup/restic snapshots

# 2. Restore file
sudo restic -r /mnt/backup/restic restore latest \
  --target /tmp/restore \
  --include "path/to/file"

# 3. Move to original location
sudo mv /tmp/restore/path/to/file /original/location
```

### Scenario 2: Database Recovery

```bash
# 1. Stop PostgreSQL
sudo systemctl stop postgresql

# 2. Restore from backup
sudo restic -r /mnt/backup/restic-db restore latest \
  --target /var/lib/postgresql

# 3. Or restore from pg_dump
gunzip -c /var/backup/postgresql/full-20260818_020000.sql.gz | \
  sudo -u postgres psql

# 4. Start PostgreSQL
sudo systemctl start postgresql
```

### Scenario 3: Full System Recovery

```bash
# 1. Boot from NixOS installer USB
# 2. Partition and format disks
# 3. Mount filesystems
mount /dev/disk/by-label/nixos /mnt
mount /dev/disk/by-label/boot /mnt/boot

# 4. Clone configuration
git clone https://github.com/Aljam/nixlab.git /mnt/etc/nixos

# 5. Restore secrets
sops decrypt secrets/hosts/r730.yaml > /mnt/var/lib/sops/age/keys.txt

# 6. Install NixOS
cd /mnt/etc/nixos
nixos-install --flake .#r730

# 7. Reboot
reboot

# 8. Restore data from backup
sudo restic -r /mnt/backup/restic restore latest --target /
```

## Offsite Backup

### rclone Configuration

```ini
# ~/.config/rclone/rclone.conf
[remote]
type = s3
provider = Backblaze
access_key_id = YOUR_KEY
secret_access_key = YOUR_SECRET
endpoint = s3.us-west-001.backblazeb2.com
bucket = nixlab-backup
```

### Automated Offsite Sync

```nix
# modules/features/backup/default.nix
{
  systemd.services.offsite-sync = {
    enable = true;
    startAt = "03:00";
    serviceConfig.ExecStart = "''
      #!/bin/sh
      rclone sync /mnt/backup remote:nixlab-backup \
        --progress --transfers=4 --checkers=8
    ''";
  };
}
```

## Best Practices

### 1. Encrypt All Backups

```bash
# restic encrypts by default
# Verify encryption
restic -r /mnt/backup/restic key list
```

### 2. Test Restores Regularly

```bash
# Monthly test restore
restic -r /mnt/backup/restic restore latest \
  --target /tmp/test-restore \
  --include "critical-file.txt"
```

### 3. Monitor Backup Health

```bash
# Check backup status daily
systemctl status restic-backups-daily
journalctl -u restic-backups-daily --since "24 hours ago"
```

### 4. Document Everything

- Backup procedures
- Recovery steps
- Contact information
- Escalation paths

### 5. Keep Secrets Secure

```bash
# Backup SOPS keys separately
cp ~/.config/sops/age/keys.txt /secure/backup/sops-keys.txt

# Encrypt the backup
age -r age1admin /secure/backup/sops-keys.txt > sops-keys.txt.age
```

---

**Last Updated**: August 2026