# Backup & Recovery

This document describes backup strategies and disaster recovery procedures for nixlab.

## Overview

A robust backup strategy protects against:
- Hardware failures
- Accidental deletions
- Ransomware/malware
- Natural disasters
- Human error

## Backup Philosophy

### 3-2-1 Rule

- **3** copies of your data
- **2** different media types
- **1** offsite backup

### What to Backup

1. **Configuration** (nixlab repository)
2. **User data** (documents, photos, etc.)
3. **Database contents** (PostgreSQL, etc.)
4. **Service data** (Jellyfin metadata, etc.)
5. **Secrets** (GPG keys, SOPS files)

## Configuration Backup

### Git Repository

The nixlab repository itself is your configuration backup:

```bash
# Ensure all changes are committed
git status
git add .
git commit -m "Latest configuration"

# Push to remote
git push origin main
```

**Best practices**:
- Commit frequently
- Use meaningful commit messages
- Push to remote immediately after changes
- Consider multiple remotes (GitHub, GitLab, self-hosted)

### Secrets Backup

```bash
# Backup GPG keys (CRITICAL)
gpg --export-secret-keys --armor YOUR_KEY_ID > gpg-backup-$(date +%Y%m%d).asc

# Store securely:
# - Encrypted USB drive
# - Password manager
# - Paper backup (gpg2paper)
# - Secure cloud storage (encrypted)

# NEVER commit GPG private keys to Git!
```

## System Backup Solutions

### Option 1: BorgBackup (Recommended)

Borg provides efficient, deduplicated backups.

#### Installation

```nix
# In your host configuration
services.borgbackup = {
  enable = true;
  jobs = {
    daily = {
      paths = [
        "/home"
        "/var/lib/postgresql"
        "/var/lib/jellyfin"
        "/etc"
      ];
      exclude = [
        "/home/*/.cache"
        "/home/*/.local/share/Trash"
      ];
      repo = "user@backup-server:/backups/${config.networking.hostName}";
      encryption = {
        mode = "repokey";
        passwordFile = "/run/secrets/borg_password";
      };
      compression = "auto,zstd";
      startAt = "02:00:00";
      prune = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 6;
      };
    };
  };
};
```

#### Manual Backup

```bash
# Initialize repository (first time)
borg init --encryption=repokey /path/to/backup

# Create backup
borg create --verbose --stats \
  /path/to/backup::{now} \
  /home \
  /var/lib/postgresql \
  --exclude '/home/*/.cache'

# List backups
borg list /path/to/backup

# Restore backup
borg extract /path/to/backup::2026-08-15 /home
```

### Option 2: Restic

Restic is simpler than Borg, with cloud storage support.

### Option 3: Sanoid (ZFS Snapshots)

For ZFS-based systems, Sanoid provides automated snapshot management.

## Database Backup

### PostgreSQL Backup

#### Automated Backup Script

```bash
#!/bin/bash
# /usr/local/bin/pg-backup.sh

BACKUP_DIR="/var/backups/postgresql"
DATE=$(date +%Y%m%d-%H%M%S)

# Create backup
pg_dumpall -U postgres | gzip > ${BACKUP_DIR}/full-backup-${DATE}.sql.gz

# Keep only last 7 days
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +7 -delete
```

#### Manual Backup

```bash
# Full backup
pg_dumpall -U postgres > backup-$(date +%Y%m%d).sql

# Single database
pg_dump -U postgres mydb > mydb-$(date +%Y%m%d).sql

# Restore
psql -U postgres -f backup-2026-08-15.sql
```

## Service-Specific Backup

### Jellyfin

```bash
# Backup Jellyfin configuration
tar -czf jellyfin-backup-$(date +%Y%m%d).tar.gz \
  /var/lib/jellyfin \
  /var/cache/jellyfin

# Restore
tar -xzf jellyfin-backup-2026-08-15.tar.gz -C /
```

### Vaultwarden

```bash
# Backup Vaultwarden data
tar -czf vaultwarden-backup-$(date +%Y%m%d).tar.gz \
  /var/lib/vaultwarden

# Restore
tar -xzf vaultwarden-backup-2026-08-15.tar.gz -C /
```

## Disaster Recovery

### Scenario 1: Single File Recovery

```bash
# From Borg backup
borg extract /path/to/backup::2026-08-15 /home/user/important-file.txt

# From ZFS snapshot
zfs rollback rpool/home@before-deletion
```

### Scenario 2: System Recovery

#### Full System Restore

```bash
# 1. Boot from NixOS installer

# 2. Restore from backup
borg extract /path/to/backup::latest /

# 3. Restore NixOS configuration
cd /etc/nixos
git clone https://github.com/Aljam/nixlab.git
cd nixlab

# 4. Rebuild system
nixos-rebuild switch --flake .#hostname

# 5. Verify services
systemctl status
```

#### Database Recovery

```bash
# 1. Stop PostgreSQL
systemctl stop postgresql

# 2. Restore from backup
gunzip -c /var/backups/postgresql/full-backup-2026-08-15.sql.gz | psql -U postgres

# 3. Start PostgreSQL
systemctl start postgresql

# 4. Verify
psql -U postgres -c "SELECT version();"
```

### Scenario 3: Complete Hardware Failure

#### Recovery Steps

1. **Provision new hardware**
   ```bash
   # Install NixOS on new machine
   # Generate hardware configuration
   nixos-generate-config --show-hardware-config > hosts/new-host/hardware-configuration.nix
   ```

2. **Clone repository**
   ```bash
   git clone https://github.com/Aljam/nixlab.git
   cd nixlab
   ```

3. **Update configuration**
   ```nix
   # Edit hosts/new-host/configuration.nix
   # Update hostname, network settings, etc.
   ```

4. **Restore secrets**
   ```bash
   # Import GPG key
   gpg --import gpg-backup-20260815.asc
   
   # Verify secrets decrypt
   sops -d secrets/secrets.yaml
   ```

5. **Build and deploy**
   ```bash
   nixos-rebuild switch --flake .#new-host
   ```

6. **Restore data**
   ```bash
   # From backup server
   borg extract /backup/path::latest /home
   borg extract /backup/path::latest /var/lib/postgresql
   ```

7. **Verify services**
   ```bash
   systemctl status
   # Check all critical services
   ```

### Scenario 4: Ransomware Attack

#### Immediate Response

1. **Isolate affected systems**
2. **Assess damage**
3. **Restore from clean backup**
4. **Rebuild system**

## Monitoring Backups

### Backup Health Check Script

```bash
#!/bin/bash
# /usr/local/bin/backup-check.sh

# Check Borg backup
borg list /backup/path > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Borg backup failed" | mail -s "Backup Alert" admin@example.com
fi

# Check last backup age
LAST_BACKUP=$(borg list /backup/path --last 1 --format '{time}' | head -1)
if [ -n "$LAST_BACKUP" ]; then
  AGE=$(( ($(date +%s) - $(date -d "$LAST_BACKUP" +%s)) / 86400 ))
  if [ $AGE -gt 2 ]; then
    echo "Backup is $AGE days old" | mail -s "Backup Warning" admin@example.com
  fi
fi
```

## Testing Backups

### Monthly Restore Test

```bash
#!/bin/bash
# Create test directory
TEST_DIR="/tmp/backup-test-$(date +%Y%m%d)"
mkdir -p $TEST_DIR

# Restore random file
borg extract /backup/path::latest /home/user/test-file.txt --target $TEST_DIR

# Verify
if [ -f "$TEST_DIR/home/user/test-file.txt" ]; then
  echo "Backup test passed"
else
  echo "Backup test FAILED" | mail -s "Backup Test Failed" admin@example.com
fi

# Cleanup
rm -rf $TEST_DIR
```

## Backup Schedule

### Recommended Schedule

| Backup Type | Frequency | Retention |
|-------------|-----------|-----------|
| Borg/Restic | Daily | 7 daily, 4 weekly, 6 monthly |
| ZFS Snapshots | Hourly | 4 hourly, 7 daily, 4 weekly |
| PostgreSQL | Daily | 7 days |
| Offsite | Weekly | 4 weeks |
| Full System | Monthly | 3 months |

## Checklist

### Daily

- [ ] Automated backup runs successfully
- [ ] Backup logs show no errors
- [ ] Disk space adequate

### Weekly

- [ ] Verify backup integrity
- [ ] Test restore of random file
- [ ] Review backup logs

### Monthly

- [ ] Full restore test
- [ ] Database restore test
- [ ] Review retention policy
- [ ] Update backup documentation

### Quarterly

- [ ] Offsite backup verification
- [ ] Disaster recovery drill
- [ ] Update backup procedures
- [ ] Review and rotate secrets

---

**Last Updated**: August 2026
