# Deployment Checklist

Use this checklist before deploying changes to production hosts in nixlab.

## Pre-Deployment

### Code Review

- [ ] Changes reviewed in Git
- [ ] All CI checks passing
- [ ] No secrets accidentally committed (gitleaks scan)
- [ ] `nix flake check` passes locally
- [ ] `nixos-rebuild build --flake .#hostname` succeeds

### Backup Verification

- [ ] Recent backup exists (within 24 hours)
- [ ] Backup integrity verified (`restic check`)
- [ ] Offsite sync completed
- [ ] SOPS keys backed up securely

### Environment Check

- [ ] Target host reachable via SSH
- [ ] Host has sufficient disk space
- [ ] No critical operations running on target
- [ ] Maintenance window scheduled (if required)

## Deployment

### Build Phase

```bash
# 1. Pull latest changes
git pull

# 2. Build configuration
nixos-rebuild build --flake .#r730

# 3. Verify build output
```

- [ ] Build completed without errors
- [ ] No unexpected warnings
- [ ] Expected services in build closure

### Test Phase

```bash
# 1. Dry-run activation
nixos-rebuild test --flake .#r730

# 2. Verify services
systemctl list-units --state=failed

# 3. Check critical services
systemctl status postgresql
systemctl status haproxy
```

- [ ] Test activation successful
- [ ] No failed services
- [ ] Critical services running

### Deploy Phase

```bash
# 1. Switch to new configuration
nixos-rebuild switch --flake .#r730

# 2. Verify activation
nixos-version
```

- [ ] Switch completed successfully
- [ ] New generation active
- [ ] All expected services running

## Post-Deployment

### Service Verification

- [ ] PostgreSQL accepting connections
- [ ] HAProxy routing correctly
- [ ] Media services accessible
- [ ] Monitoring dashboards updating
- [ ] Backup jobs scheduled

### Health Checks

```bash
# Check system health
nixos-version
uname -r
df -h
free -h

# Check service health
systemctl status postgresql
systemctl status haproxy

# Check logs
journalctl -p 3 -xb
```

- [ ] System resources normal (CPU, memory, disk)
- [ ] No critical errors in logs
- [ ] All services healthy

### Rollback Plan

```bash
# If issues occur, rollback:
nixos-rebuild switch --rollback

# Or switch to specific generation
nix-store --list-generations /nix/var/nix/profiles/system
nixos-rebuild switch --switch-generation 42
```

- [ ] Rollback procedure documented
- [ ] Previous generation available
- [ ] Team notified of rollback capability

## Service-Specific Checks

### Database (PostgreSQL)

```bash
# Check PostgreSQL status
sudo -u postgres psql -c "SELECT version();"

# Verify connections
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"
```

- [ ] PostgreSQL running
- [ ] Connections accepted
- [ ] Backups running

### Media Services

```bash
# Check Jellyfin
curl -I http://localhost:8096/health

# Check Sonarr
curl -I http://localhost:8989/api/v3/system/status?apiKey=YOUR_KEY
```

- [ ] Jellyfin accessible
- [ ] Sonarr accessible
- [ ] Radarr accessible

### Reverse Proxy (HAProxy)

```bash
# Check HAProxy status
sudo systemctl status haproxy

# Test routing
curl -I https://jellyfin.example.com
curl -I https://sonarr.example.com
```

- [ ] HAProxy running
- [ ] All backends healthy
- [ ] SSL certificates valid

### Monitoring

```bash
# Check Prometheus
curl http://localhost:9090/api/v1/targets

# Check Grafana
curl http://localhost:3000/api/health
```

- [ ] Prometheus scraping targets
- [ ] Grafana accessible
- [ ] Metrics flowing

## Security Checks

### Firewall

```bash
# Check firewall status
sudo nft list ruleset

# Verify allowed ports
sudo ss -tulpn | grep LISTEN
```

- [ ] Only expected ports open
- [ ] Firewall rules applied

### SSH

```bash
# Check SSH status
sudo systemctl status sshd

# Verify key-based auth
ssh -o PreferredAuthentications=publickey user@hostname
```

- [ ] SSH running
- [ ] Key-based auth working

## Quick Reference

### Common Commands

```bash
# Build
nixos-rebuild build --flake .#hostname

# Test
nixos-rebuild test --flake .#hostname

# Deploy
nixos-rebuild switch --flake .#hostname

# Rollback
nixos-rebuild switch --rollback

# Check generation
nix-store --list-generations /nix/var/nix/profiles/system

# View logs
journalctl -u service-name -f

# Check services
systemctl list-units --state=failed
```

---

**Last Updated**: August 2026