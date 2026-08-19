# Getting Started with nixlab

This guide walks you through setting up and using the nixlab infrastructure repository for the first time.

## Prerequisites

### Hardware Requirements

- **NixOS-compatible hardware**: This repository targets Dell PowerEdge servers (R820, R730, R730XD) and custom x86_64 systems
- **Network connectivity**: All hosts should be on the same network segment or reachable via SSH
- **Storage**: Minimum 50GB for system partition, additional storage for roles (database, media, etc.)

### Software Requirements

- **NixOS** (unstable or 24.05+) with flakes enabled
- **Git** for version control
- **SOPS** for secret management
- **Cachix CLI** (optional but recommended for faster builds)
- **age** or **GPG** for SOPS key management

### Enable Flakes on NixOS

If you're on NixOS without flakes enabled:

```nix
# /etc/nixos/configuration.nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Aljam/nixlab.git
cd nixlab
```

### 2. Set Up SOPS Encryption

#### Generate age Key

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

#### Add Your Key to `.sops.yaml`

Edit `.sops.yaml` and add your age public key to the `age` section:

```yaml
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: >-
      YOUR_AGE_PUBLIC_KEY,
      EXISTING_KEY_1,
      EXISTING_KEY_2
```

#### Verify SOPS Configuration

```bash
sops decrypt secrets/shared/example.enc.yaml
```

### 3. Configure Cachix (Optional but Recommended)

#### Create a Cachix Cache

```bash
cachix create your-username-nixlab
cachix authtoken
```

#### Add Cachix to Your System

```bash
# On NixOS, add to configuration.nix
{
  nix.settings.substituters = [ "https://your-username-nixlab.cachix.org" ];
  nix.settings.trusted-public-keys = [ "your-username-nixlab.cachix.org-1:YOUR_KEY" ];
}
```

#### Use Cachix in This Repository

```bash
cachix use your-username-nixlab
```

See [CACHIX.md](../CACHIX.md) for detailed setup instructions.

### 4. Bootstrap Your First Host

#### Choose a Host Configuration

List available hosts:

```bash
ls hosts/
# navi  oryx  r730  r730xd  r820
```

#### Build and Deploy

For a Dell R730:

```bash
# Build the configuration
nixos-rebuild build --flake .#r730

# Deploy to local machine (if running on R730 hardware)
nixos-rebuild switch --flake .#r730

# Or deploy remotely
nixos-rebuild switch --flake .#r730 --target-host root@r730.local
```

#### For Custom Hardware

If you're not using Dell hardware, create a new host configuration:

```bash
# Create host directory
mkdir -p hosts/myhost

# Copy and adapt an existing configuration
cp hosts/r730/default.nix hosts/myhost/default.nix

# Edit for your hardware
nvim hosts/myhost/default.nix

# Add to flake.nix outputs
# Then build
nixos-rebuild switch --flake .#myhost
```

## Post-Installation

### Verify System State

```bash
# Check NixOS version
nixos-version

# Verify flake inputs
nix flake info

# Check running services
systemctl list-units --type=service --state=running
```

### Configure Users

User configurations are in `users/`. To add yourself:

```bash
# Copy existing user config
cp -r users/aljam users/yourname

# Edit with your details
nvim users/yourname/default.nix

# Add to host configuration
# hosts/myhost/default.nix
{
  imports = [
    ../../users/yourname
  ];
}
```

### Set Up Secrets

Decrypt and inspect existing secrets:

```bash
sops decrypt secrets/shared/example.enc.yaml
```

Add new secrets:

```bash
# Create plaintext secret
cat > secrets/shared/my-secret.yaml <<EOF
api_key: "your-api-key"
password: "super-secret"
EOF

# Encrypt
sops encrypt secrets/shared/my-secret.yaml > secrets/shared/my-secret.enc.yaml

# Remove plaintext
rm secrets/shared/my-secret.yaml

# Commit encrypted secret
git add secrets/shared/my-secret.enc.yaml
git commit -m "Add my-secret"
```

### Configure Network

Edit network settings in your host configuration:

```nix
# hosts/myhost/default.nix
{
  networking = {
    hostName = "myhost";
    interfaces.eno1 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.100";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };
}
```

## Common Workflows

### Daily Rebuild

```bash
# Pull latest changes
git pull

# Rebuild with current configuration
nixos-rebuild switch --flake .#myhost
```

### Update Flake Inputs

```bash
# Update all inputs to latest versions
nix flake update

# Update specific input
nix flake update nixpkgs

# Rebuild with updated inputs
nixos-rebuild switch --flake .#myhost
```

### Debugging Builds

```bash
# Show build output
nixos-rebuild build --show-trace --flake .#myhost

# Check for evaluation errors
nix flake check

# Inspect Nix store path
nix-store -q --tree $(nixos-rebuild build --flake .#myhost)
```

### Rollback

```bash
# Rollback to previous generation
nixos-rebuild switch --rollback

# List generations
nix-store --list-generations /nix/var/nix/profiles/system

# Switch to specific generation
nixos-rebuild switch --switch-generation 42
```

## Next Steps

- **[Architecture](ARCHITECTURE.md)** - Understand the module system and repository layout
- **[Roles](ROLES.md)** - Learn about service roles and how to compose them
- **[Secrets](SECRETS.md)** - Deep dive into SOPS encryption and key management
- **[Networking](NETWORKING.md)** - Configure firewall rules and network topology
- **[Backup & Recovery](BACKUP-RECOVERY.md)** - Set up disaster recovery procedures

## Troubleshooting

### Build Fails with "Input Not Found"

```bash
# Update flake.lock
nix flake update

# Or check input names in flake.nix
cat flake.nix | grep -A 5 "inputs"
```

### SOPS Decryption Fails

```bash
# Verify age key is in ~/.config/sops/age/keys.txt
cat ~/.config/sops/age/keys.txt

# Check .sops.yaml configuration
cat .sops.yaml

# Test decryption
sops decrypt secrets/shared/example.enc.yaml
```

### Cachix Cache Miss

```bash
# Verify cache is configured
cachix use your-username-nixlab

# Check substituters
nix show-config | grep substituters

# Build without cache (fallback to source)
nixos-rebuild switch --flake .#myhost --option substituters ""
```

### Service Fails to Start

```bash
# Check service status
systemctl status myservice

# View logs
journalctl -u myservice -f

# Validate NixOS configuration
nixos-rebuild build --flake .#myhost
```

## Getting Help

- **Documentation**: Browse the [`docs/`](../docs/) directory
- **NixOS Wiki**: https://wiki.nixos.org
- **NixOS Discourse**: https://discourse.nixos.org
- **GitHub Issues**: https://github.com/Aljam/nixlab/issues

---

**Last Updated**: August 2026