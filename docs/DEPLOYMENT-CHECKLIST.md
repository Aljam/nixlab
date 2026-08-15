# Deployment Checklist

Use this checklist when deploying nixlab to ensure nothing is missed.

## Pre-Deployment

### System Requirements

- [ ] NixOS installed (26.05 or later recommended)
- [ ] Flakes enabled in Nix
- [ ] Minimum 4GB RAM (8GB+ recommended)
- [ ] Minimum 20GB free storage
- [ ] Network connectivity

### Prerequisites

- [ ] Git installed
- [ ] SOPS installed (`nix-env -iA nixpkgs.sops`)
- [ ] GPG installed (`nix-env -iA nixpkgs.gnupg`)
- [ ] GPG key generated
- [ ] GPG key exported and backed up securely

### Repository Setup

- [ ] Clone repository: `git clone https://github.com/Aljam/nixlab.git`
- [ ] Navigate to directory: `cd nixlab`
- [ ] Verify flake: `nix flake check`
- [ ] Review available hosts: `ls hosts/`
- [ ] Review available roles: `ls modules/roles/`

## Host Configuration

### Choose Host Type

- [ ] Desktop workstation → `desktop-node` role
- [ ] Headless server → `server-core` role
- [ ] Media server → `media-node` role
- [ ] Email server → `mail-node` role
- [ ] NAS/Storage → `storage-node` role
- [ ] AI/ML compute → `ai-node` role

### Create Host Directory

- [ ] Create directory: `mkdir -p hosts/<hostname>`
- [ ] Create configuration file: `touch hosts/<hostname>/configuration.nix`
- [ ] Edit configuration with appropriate imports

### Generate Hardware Configuration

- [ ] Generate: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
- [ ] Review generated file
- [ ] Remove unnecessary comments
- [ ] Adjust disk layout if needed
- [ ] Add hardware-specific settings

### Configure Host

- [ ] Set hostname in configuration
- [ ] Import appropriate role module
- [ ] Import appropriate hardware module
- [ ] Import user configuration
- [ ] Add network configuration
- [ ] Add any host-specific overrides
- [ ] Review configuration for errors

### Secrets Setup (if needed)

- [ ] Review `.sops.yaml` configuration
- [ ] Verify GPG key is in `.sops.yaml`
- [ ] Edit secrets: `sops secrets/secrets.yaml`
- [ ] Add required secrets
- [ ] Verify encryption: `sops -d secrets/secrets.yaml`
- [ ] Reference secrets in host configuration
- [ ] Test decryption on target host

## Testing

### Build Test

- [ ] Test build: `nixos-rebuild build --flake .#<hostname>`
- [ ] Review build output for warnings
- [ ] Fix any errors
- [ ] Verify all services enabled
- [ ] Check for missing dependencies

### Configuration Verification

- [ ] Verify imports are correct
- [ ] Check for circular dependencies
- [ ] Review enabled services
- [ ] Verify firewall rules
- [ ] Check network configuration
- [ ] Review security settings

### Service Test (if applicable)

- [ ] Test in VM: `nixos-rebuild build-vm --flake .#<hostname>`
- [ ] Start VM and verify services
- [ ] Test critical services
- [ ] Check logs for errors

## Deployment

### Initial Deployment

- [ ] Backup current configuration (if upgrading)
- [ ] Deploy: `nixos-rebuild switch --flake .#<hostname>`
- [ ] Monitor deployment output
- [ ] Wait for activation to complete
- [ ] Verify no errors during activation

### Post-Deployment Verification

- [ ] Check hostname: `hostname`
- [ ] Verify user access: `whoami`
- [ ] Check network: `ping -c 3 example.com`
- [ ] List services: `systemctl list-units --state=running`
- [ ] Check for failed services: `systemctl --failed`
- [ ] Verify disk usage: `df -h`
- [ ] Check memory: `free -h`

### Service Verification

For each enabled service:

- [ ] Service is running: `systemctl status <service>`
- [ ] Service is enabled: `systemctl is-enabled <service>`
- [ ] Check service logs: `journalctl -u <service> -b`
- [ ] Test service functionality
- [ ] Verify service is accessible (if network service)

### Security Verification

- [ ] Firewall is active: `systemctl status nftables` or `firewalld`
- [ ] SSH is configured correctly
- [ ] Unnecessary services are disabled
- [ ] Secrets are accessible: `ls -la /run/secrets/`
- [ ] User permissions are correct
- [ ] Sudo access works

## Post-Deployment

### Documentation

- [ ] Update hosts inventory in README
- [ ] Document any custom configurations
- [ ] Note any deviations from standard setup
- [ ] Update network diagram (if maintained)
- [ ] Record deployment date and version

### Backup Setup

- [ ] Configure backup solution (Borg/Restic/ZFS)
- [ ] Test backup creation
- [ ] Verify backup can be restored
- [ ] Set up backup monitoring
- [ ] Schedule regular backups
- [ ] Configure offsite backup

### Monitoring Setup

- [ ] Enable monitoring (if not already)
- [ ] Configure alerts
- [ ] Set up dashboards (Grafana)
- [ ] Verify metrics collection
- [ ] Test alert notifications

### Maintenance Planning

- [ ] Schedule regular updates
- [ ] Plan secret rotation schedule
- [ ] Set up update notifications
- [ ] Document maintenance procedures
- [ ] Create rollback plan

## Specific Host Types

### Desktop Deployment

Additional checks:

- [ ] GUI starts correctly
- [ ] Display resolution is correct
- [ ] Audio works
- [ ] Bluetooth works (if applicable)
- [ ] WiFi works (if applicable)
- [ ] User applications are available
- [ ] Input devices work (keyboard, mouse)

### Server Deployment

Additional checks:

- [ ] SSH access works remotely
- [ ] Network services are accessible
- [ ] Firewall rules are correct
- [ ] No GUI components (unless needed)
- [ ] Services start on boot
- [ ] Remote management works (IPMI, etc.)

### Media Server Deployment

Additional checks:

- [ ] Jellyfin web interface accessible
- [ ] *arr services running
- [ ] Storage mounts working
- [ ] Transcoding works (if applicable)
- [ ] Network shares accessible
- [ ] Download services working

### Database Server Deployment

Additional checks:

- [ ] Database service running
- [ ] Can connect locally
- [ ] Can connect remotely (if applicable)
- [ ] Backup configured
- [ ] Performance acceptable
- [ ] Security hardened

## Troubleshooting

### Common Issues

**Build fails**:
- [ ] Check error message
- [ ] Verify all imports exist
- [ ] Check for syntax errors
- [ ] Review flake inputs
- [ ] Run with `--show-trace`

**Service not starting**:
- [ ] Check service status: `systemctl status <service>`
- [ ] Check logs: `journalctl -u <service>`
- [ ] Verify configuration
- [ ] Check dependencies
- [ ] Test manual start

**Network issues**:
- [ ] Check interface: `ip addr`
- [ ] Check routing: `ip route`
- [ ] Check firewall: `nft list ruleset`
- [ ] Test connectivity: `ping`, `curl`
- [ ] Check DNS: `cat /etc/resolv.conf`

**Secrets not available**:
- [ ] Check GPG keys: `gpg --list-secret-keys`
- [ ] Test decryption: `sops -d secrets/secrets.yaml`
- [ ] Check sops-nix configuration
- [ ] Verify secret paths
- [ ] Check permissions

### Rollback Procedure

If deployment fails:

- [ ] Rollback: `nixos-rebuild switch --rollback`
- [ ] Verify system is functional
- [ ] Review logs for errors
- [ ] Fix configuration
- [ ] Test again before redeploying

## Final Steps

### Cleanup

- [ ] Remove old generations: `nix-collect-garbage --delete-older-than 7d`
- [ ] Clean nix store: `nix-store --gc`
- [ ] Remove temporary files
- [ ] Clean build artifacts

### Commit Changes

- [ ] Commit configuration: `git add .`
- [ ] Write meaningful commit message
- [ ] Commit: `git commit -m "Add <hostname> configuration"`
- [ ] Push to remote: `git push origin main`

### Update Documentation

- [ ] Update README with new host
- [ ] Update network diagram (if applicable)
- [ ] Document any special configurations
- [ ] Update this checklist if needed

### Notify Stakeholders

- [ ] Inform users of new host (if applicable)
- [ ] Update status page (if applicable)
- [ ] Document in team wiki (if applicable)
- [ ] Schedule follow-up review

## Ongoing Maintenance

### Daily

- [ ] Check system health
- [ ] Review logs for errors
- [ ] Verify backups completed
- [ ] Check disk space

### Weekly

- [ ] Review security updates
- [ ] Check service status
- [ ] Review backup logs
- [ ] Test restore procedure (monthly)

### Monthly

- [ ] Apply security updates
- [ ] Review system performance
- [ ] Rotate secrets (if scheduled)
- [ ] Update documentation
- [ ] Review and clean old generations

### Quarterly

- [ ] Full system backup test
- [ ] Disaster recovery drill
- [ ] Review and update configurations
- [ ] Audit access and permissions
- [ ] Review monitoring and alerts

## Sign-Off

### Deployment Completed

- [ ] All pre-deployment tasks complete
- [ ] Configuration tested and verified
- [ ] Deployment successful
- [ ] All services running
- [ ] Documentation updated
- [ ] Backup configured
- [ ] Monitoring enabled
- [ ] Stakeholders notified

**Deployed by**: ________________  
**Date**: ________________  
**Host**: ________________  
**Version/Commit**: ________________  

**Notes**:

---

## Quick Reference

### Essential Commands

```bash
# Build and test
nixos-rebuild build --flake .#hostname
nixos-rebuild build-vm --flake .#hostname

# Deploy
nixos-rebuild switch --flake .#hostname

# Rollback
nixos-rebuild switch --rollback

# Check system
systemctl status
systemctl --failed
journalctl -b

# Cleanup
nix-collect-garbage --delete-older-than 7d
nix-store --gc
```

### Important Files

- `hosts/<hostname>/configuration.nix` - Host config
- `hosts/<hostname>/hardware-configuration.nix` - Hardware config
- `secrets/secrets.yaml` - Encrypted secrets
- `.sops.yaml` - SOPS policy
- `modules/roles/*.nix` - Role definitions

---

**Last Updated**: August 2026
