# Setup Guide

This guide walks you through the initial setup and bootstrapping of nixlab infrastructure.

## Prerequisites

### Hardware

- **Dell PowerEdge servers** (R820, R730, R730XD) or compatible x86_64 hardware
- **Network switch** with gigabit Ethernet
- **Storage** (HDD/SSD/NVMe) appropriate for roles
- **USB drive** (8GB+) for NixOS installer

### Software

- **NixOS ISO** (latest unstable or 24.05+)
- **age** or **GPG** for SOPS encryption
- **Git** for version control
- **SOPS** for secret management

## Initial Installation

### 1. Prepare NixOS Installer

```bash
# Download NixOS ISO
wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso

# Write to USB
sudo dd if=nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
```

### 2. Boot Target Host

```bash
# Insert USB and boot
# At boot menu, select NixOS installer
# Wait for shell prompt
```

### 3. Partition Disks

```bash
# Example for UEFI + ZFS
# Disk: /dev/sda

# Create partitions
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary fat32 1M 512M
parted /dev/sda -- mkpart primary 512M 100%
parted /dev/sda -- set 1 boot on

# Format boot partition
mkfs.fat -F 32 /dev/sda1

# Create ZFS pool
zpool create -f -O mountpoint=none rpool /dev/sda2

# Create ZFS datasets
zfs create -o mountpoint=legacy rpool/root
zfs create -o mountpoint=legacy rpool/home
zfs create -o mountpoint=legacy rpool/nix

# Mount filesystems
mount /dev/zvol/rpool/root /mnt
mkdir -p /mnt/{boot,home,nix}
mount /dev/sda1 /mnt/boot
mount /dev/zvol/rpool/home /mnt/home
mount /dev/zvol/rpool/nix /mnt/nix
```

### 4. Generate Hardware Configuration

```bash
# Generate hardware config
nixos-generate-config --root /mnt

# Edit configuration
nvim /mnt/etc/nixos/configuration.nix
```

### 5. Configure Base System

```nix
# /mnt/etc/nixos/configuration.nix
{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  
  system.stateVersion = "24.05";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "r730";
  networking.interfaces.eno1.useDHCP = true;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  services.openssh.enable = true;
  
  users.users.root.password = "temp-password";
  users.users.aljam = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "temp-password";
  };
  
  security.sudo.wheelNeedsPassword = false;
}
```

### 6. Install NixOS

```bash
# Install
nixos-install

# Set root password
nixos-enter
passwd
exit

# Reboot
reboot
```

## Post-Installation Setup

### 1. Clone nixlab Repository

```bash
# Login as root or user
ssh root@r730

# Clone repository
git clone https://github.com/Aljam/nixlab.git
cd nixlab
```

### 2. Set Up SOPS

```bash
# Install SOPS
nix-env -iA nixpkgs.sops

# Generate age key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Add public key to .sops.yaml
nvim .sops.yaml
```

### 3. Configure Cachix

```bash
# Install Cachix
nix-env -iA nixpkgs.cachix

# Authenticate
cachix authtoken

# Use cache
cachix use your-username-nixlab
```

### 4. Build Initial Configuration

```bash
# Build with nixlab configuration
nixos-rebuild switch --flake .#r730

# Verify
nixos-version
systemctl list-units --state=running
```

### 5. Set Up Secrets

```bash
# Decrypt existing secrets
sops decrypt secrets/shared/example.enc.yaml

# Add new secrets
cat > secrets/shared/database.yaml <<EOF
postgres:
  password: "secure-password"
EOF

sops encrypt secrets/shared/database.yaml > secrets/shared/database.enc.yaml
rm secrets/shared/database.yaml

# Commit
git add secrets/shared/database.enc.yaml
git commit -m "Add database secrets"
```

### 6. Configure Users

```nix
# users/aljam/default.nix
{
  users.users.aljam = {
    isNormalUser = true;
    description = "Aljam";
    home = "/home/aljam";
    createHome = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" "video" ];
    
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA..."
    ];
  };
  
  programs.zsh.enable = true;
}
```

### 7. Configure Network

```nix
# hosts/r730/default.nix
{
  networking = {
    hostName = "r730";
    
    interfaces.eno1 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.20";
          prefixLength = 24;
        }
      ];
    };
    
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" "1.1.1.1" ];
  };
}
```

### 8. Enable Roles

```nix
# hosts/r730/default.nix
{
  imports = [
    ../../modules/roles/database
    ../../modules/roles/monitoring
  ];
  
  roles.database = {
    enable = true;
    postgres = {
      enable = true;
      version = 15;
    };
  };
  
  roles.monitoring = {
    enable = true;
    prometheus.enable = true;
    grafana.enable = true;
  };
}
```

## Verification

### System Health

```bash
# Check NixOS version
nixos-version

# Check running services
systemctl list-units --state=running | wc -l

# Check failed services
systemctl list-units --state=failed

# Check disk usage
df -h

# Check memory
free -h
```

### Service Health

```bash
# PostgreSQL
sudo -u postgres psql -c "SELECT version();"

# Grafana
curl http://localhost:3000/api/health

# Prometheus
curl http://localhost:9090/api/v1/targets
```

### Network

```bash
# Check connectivity
ping -c 4 192.168.1.1

# Check DNS
dig example.com

# Check open ports
ss -tulpn | grep LISTEN
```

## Adding Additional Hosts

### 1. Repeat Installation

Follow steps 1-6 for each new host.

### 2. Create Host Configuration

```bash
# Create host directory
mkdir -p hosts/newhost

# Copy and adapt existing config
cp hosts/r730/default.nix hosts/newhost/default.nix

# Edit for new host
nvim hosts/newhost/default.nix
```

### 3. Add to Flake

```nix
# flake.nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations = {
    r730 = import ./hosts/r730;
    newhost = import ./hosts/newhost;  # Add this line
  };
};
```

### 4. Build and Deploy

```bash
# Build
nixos-rebuild build --flake .#newhost

# Deploy
nixos-rebuild switch --flake .#newhost
```

## Troubleshooting

### Build Fails

```bash
# Check for errors
nixos-rebuild build --show-trace --flake .#r730

# Check flake
nix flake check
```

### Service Fails to Start

```bash
# Check service status
systemctl status servicename

# View logs
journalctl -u servicename -f

# Check configuration
nixos-rebuild build --flake .#r730
```

### Network Issues

```bash
# Check interface
ip addr show

# Check routing
ip route show

# Check DNS
cat /etc/resolv.conf
```

### SOPS Issues

```bash
# Verify age key
cat ~/.config/sops/age/keys.txt

# Test decryption
sops decrypt secrets/shared/example.enc.yaml

# Check .sops.yaml
cat .sops.yaml
```

## Next Steps

- **[Architecture](ARCHITECTURE.md)** - Understand the module system
- **[Roles](ROLES.md)** - Learn about service roles
- **[Secrets](SECRETS.md)** - Deep dive into SOPS
- **[Networking](NETWORKING.md)** - Configure network topology
- **[Backup & Recovery](BACKUP-RECOVERY.md)** - Set up disaster recovery

---

**Last Updated**: August 2026