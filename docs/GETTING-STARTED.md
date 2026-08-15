# Getting Started with nixlab

This guide will help you set up and deploy nixlab on a new machine.

## Prerequisites

### System Requirements

- **NixOS**: Version 24.05 or later recommended
- **Flakes**: Must be enabled in Nix
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Storage**: Minimum 20GB free space

### Required Tools

```bash
# NixOS with flakes enabled
# Verify flakes are enabled:
nix flake --version

# SOPS for secrets management
nix-env -iA nixpkgs.sops

# GPG for encryption
nix-env -iA nixpkgs.gnupg
```

### Enable Flakes (if not already enabled)

Add to `~/.config/nix/nix.conf`:

```conf
experimental-features = nix-command flakes
```

Or add to `/etc/nix/nix.conf` for system-wide:

```conf
experimental-features = nix-command flakes
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Aljam/nixlab.git
cd nixlab
```

### 2. Choose or Create a Host Configuration

#### Option A: Use Existing Host

If your hardware matches an existing host:

```bash
# List available hosts
ls hosts/

# Example: if you have a Dell PowerEdge R730
# You can use the r730 configuration as a starting point
```

#### Option B: Create New Host

See [Adding a New Host](#adding-a-new-host) below.

### 3. Generate Hardware Configuration

```bash
# Generate hardware-specific configuration
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

Edit the generated file to:
- Remove unnecessary comments
- Adjust disk layout if needed
- Add any hardware-specific settings

### 4. Configure Host

Edit `hosts/<hostname>/configuration.nix`:

```nix
{
  imports = [
    # Choose appropriate role
    ../../modules/roles/desktop-node.nix    # For desktop
    # ../../modules/roles/server-core.nix   # For server
    # ../../modules/roles/media-node.nix    # For media server
    
    # Choose hardware module
    # ../../modules/hardware/dell-poweredge.nix
    # ../../modules/hardware/system76-laptop.nix
    ../../modules/hardware/navi-desktop.nix
    
    # User configuration
    ../../users/aljam
  ];
  
  # Set hostname
  networking.hostName = "<hostname>";
  
  # Add host-specific overrides here
}
```

### 5. Build and Test

```bash
# Test build (doesn't activate)
nixos-rebuild build --flake .#<hostname>

# If successful, activate
nixos-rebuild switch --flake .#<hostname>
```

### 6. Verify Deployment

```bash
# Check hostname
hostname

# Check services
systemctl status

# Verify user
whoami
```

## Adding a New Host

### Step 1: Create Host Directory

```bash
mkdir -p hosts/<hostname>
```

### Step 2: Create Configuration File

Create `hosts/<hostname>/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    # Base role - choose one:
    ../../modules/roles/common.nix          # Minimal
    ../../modules/roles/desktop-node.nix    # Desktop with GUI
    ../../modules/roles/server-core.nix     # Headless server
    ../../modules/roles/media-node.nix      # Media server
    ../../modules/roles/mail-node.nix       # Email server
    ../../modules/roles/storage-node.nix    # NAS
    ../../modules/roles/ai-node.nix         # AI/ML compute
    
    # Hardware configuration - choose one:
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/hardware/system76-laptop.nix
    ../../modules/hardware/navi-desktop.nix
    
    # User configuration
    ../../users/aljam
  ];
  
  # Hostname (required)
  networking.hostName = "<hostname>";
  
  # Network configuration
  networking.networkmanager.enable = true;
  
  # Add any host-specific overrides
  # Example: enable NVIDIA on AI node
  # services.xserver.videoDrivers = [ "nvidia" ];
}
```

### Step 3: Generate Hardware Configuration

```bash
# Boot into a temporary NixOS installer or live environment
sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

Review and edit `hardware-configuration.nix`:
- Remove commented-out options
- Adjust file systems if needed
- Add any hardware-specific settings

### Step 4: Add Secrets (Optional)

If the host needs secrets (API keys, passwords, etc.):

1. Edit `secrets/secrets.yaml`
2. Add secret with host-specific access
3. Encrypt with SOPS:
   ```bash
   sops secrets/secrets.yaml
   ```

See [Secrets Management](SECRETS.md) for details.

### Step 5: Test Build

```bash
# Test the configuration
nixos-rebuild build --flake .#<hostname>

# If successful, deploy
nixos-rebuild switch --flake .#<hostname>
```

## Common Scenarios

### Scenario 1: New Desktop Computer

```nix
# hosts/new-desktop/configuration.nix
{
  imports = [
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/navi-desktop.nix  # Or create new hardware module
    ../../users/aljam
  ];
  
  networking.hostName = "new-desktop";
  
  # Desktop-specific overrides
  services.xserver.videoDrivers = [ "nvidia" ];  # If using NVIDIA
}
```

### Scenario 2: New Server

```nix
# hosts/new-server/configuration.nix
{
  imports = [
    ../../modules/roles/server-core.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../users/aljam
  ];
  
  networking.hostName = "new-server";
  
  # Server-specific overrides
  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "192.168.1.100";
      prefixLength = 24;
    }
  ];
}
```

### Scenario 3: Media Server

```nix
# hosts/media/configuration.nix
{
  imports = [
    ../../modules/roles/media-node.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../users/aljam
  ];
  
  networking.hostName = "media";
  
  # Media-specific overrides
  # Add storage mounts
  # Configure network
}
```

## Building and Deploying

### Build Commands

```bash
# Test build (doesn't activate)
nixos-rebuild build --flake .#<hostname>

# Activate new configuration
nixos-rebuild switch --flake .#<hostname>

# Boot into configuration on next reboot
nixos-rebuild boot --flake .#<hostname>

# Test configuration in VM
nixos-rebuild build-vm --flake .#<hostname>
```

### Deploy to Remote Host

```bash
# Build locally and deploy via SSH
nixos-rebuild switch --flake .#<hostname> --target-host user@<hostname>

# With build on remote host
nixos-rebuild switch --flake .#<hostname> --target-host user@<hostname> --build-host user@<hostname>
```

### Rollback

```bash
# Rollback to previous generation
nixos-rebuild switch --rollback

# List generations
nixos-rebuild list-generations

# Switch to specific generation
nixos-rebuild switch --generation <number>
```

## Troubleshooting

### Build Fails

**Problem**: `error: attribute 'xyz' missing`

**Solution**: Check that all imports are correct and modules exist.

```bash
# Verify flake
nix flake check

# Show detailed error
nixos-rebuild build --flake .#<hostname> --show-trace
```

### Hardware Not Detected

**Problem**: Network, GPU, or other hardware not working

**Solution**: 
1. Check `hardware-configuration.nix` for correct drivers
2. Add hardware-specific module if needed
3. Verify kernel modules are loaded

```bash
# Check loaded modules
lsmod

# Check hardware
lspci
lsusb
```

### Services Not Starting

**Problem**: Service fails to start after deployment

**Solution**:

```bash
# Check service status
systemctl status <service-name>

# Check logs
journalctl -u <service-name> -b

# Restart service
sudo systemctl restart <service-name>
```

### Secrets Not Decrypted

**Problem**: SOPS secrets not available

**Solution**:

```bash
# Verify GPG key is available
gpg --list-secret-keys

# Check SOPS configuration
cat .sops.yaml

# Test decryption
sops -d secrets/secrets.yaml
```

## Next Steps

After successfully deploying:

1. **Customize Configuration**: Edit role and feature modules
2. **Add Users**: Create user configurations in `users/`
3. **Set Up Monitoring**: Enable Grafana/Prometheus
4. **Configure Backups**: Set up backup strategy
5. **Add More Hosts**: Scale to multiple machines

## Additional Resources

- [Architecture](ARCHITECTURE.md) - System design
- [Roles](ROLES.md) - Role documentation
- [Secrets](SECRETS.md) - Secrets management
- [Backup & Recovery](BACKUP-RECOVERY.md) - Disaster recovery

## Getting Help

- Check existing issues in the repository
- Review NixOS documentation: https://nixos.org/manual/nixos/stable/
- NixOS community: https://nixos.org/community/

---

**Last Updated**: August 2026
