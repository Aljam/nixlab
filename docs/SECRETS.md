# Secrets Management

This document describes how to manage secrets (passwords, API keys, certificates) in nixlab using SOPS and GPG.

## Overview

nixlab uses **SOPS** (Secrets OPerationS) for encrypting secrets, integrated with NixOS via **sops-nix**.

### Why SOPS?

- **Git-friendly**: Encrypted files can be safely committed
- **Multi-key**: Multiple GPG keys can decrypt the same secret
- **Host-specific**: Different hosts can access different secrets
- **Audit trail**: Version control shows what secrets exist (not their values)
- **NixOS integration**: Secrets are automatically decrypted at build time

## Architecture

```
secrets/
├── secrets.yaml          # Encrypted secrets file
└── .sops.yaml           # SOPS encryption policy

GPG Keys:
├── User keys (for decryption)
└── Host keys (for machine-specific access)
```

### Secret Flow

```
1. Create/edit secret in secrets/secrets.yaml
2. SOPS encrypts with configured GPG keys
3. Commit encrypted file to Git
4. NixOS build references secret
5. sops-nix decrypts at activation time
6. Secret available in /run/secrets/
```

## Prerequisites

### Install Required Tools

```bash
# On NixOS
nix-env -iA nixpkgs.sops
nix-env -iA nixpkgs.gnupg

# Or via Nix
nix-shell -p sops gnupg
```

### Generate GPG Key

If you don't have a GPG key:

```bash
# Generate new key
gpg --full-generate-key

# Choose:
# - Key type: RSA and RSA (default)
# - Key size: 4096
# - Expiration: 1y (or 0 for no expiration)
# - Real name: Your Name
# - Email: your@email.com
# - Comment: nixlab secrets
# - Passphrase: (choose a strong one)
```

### Export GPG Key ID

```bash
# List secret keys
gpg --list-secret-keys --keyid-format LONG

# Copy the key ID (e.g., ABCD1234EF567890)
```

## Initial Setup

### 1. Configure SOPS

Create `.sops.yaml` in repository root:

```yaml
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
    - gpg:
      # Add your GPG key ID
      - ABCD1234EF567890
      
      # Add host keys for machine-specific access
      # - HOST_KEY_ID_1
      # - HOST_KEY_ID_2
```

### 2. Create Secrets File

```bash
# Create initial secrets file
touch secrets/secrets.yaml

# Encrypt with SOPS
sops secrets/secrets.yaml
```

This opens your editor to add secrets.

### 3. Add Secrets

In the editor, add secrets in YAML format:

```yaml
# Database passwords
database_password: "super-secret-password"

# API keys
api_key: "sk-1234567890abcdef"

# Certificates
cert_pem: |
  -----BEGIN CERTIFICATE-----
  MIID...
  -----END CERTIFICATE-----

# Host-specific secrets
host_navi_password: "navi-secret"
host_oryx_password: "oryx-secret"
```

Save and exit - SOPS encrypts automatically.

## Using Secrets in NixOS

### Basic Usage

```nix
# In your host configuration
{ config, pkgs, ... }:

{
  # Import sops-nix module
  imports = [
    # ... your other imports
  ];
  
  # Configure sops
  sops = {
    # Enable sops
    defaultSopsFile = ../secrets/secrets.yaml;
    
    # Define secrets
    secrets = {
      database_password = {};
      api_key = {};
    };
  };
  
  # Use secrets in services
  services.postgresql = {
    enable = true;
    initialScript = ''
      CREATE USER myuser WITH PASSWORD '${config.sops.secrets.database_password.path}';
    '';
  };
  
  # Or use in environment
  environment.variables.API_KEY_FILE = config.sops.secrets.api_key.path;
}
```

## Common Operations

### Add New Secret

```bash
# Edit secrets file (automatically decrypts)
sops secrets/secrets.yaml

# Add new secret in editor:
# new_secret: "secret-value"

# Save and exit (automatically encrypts)
```

### Update Existing Secret

```bash
# Edit secrets file
sops secrets/secrets.yaml

# Modify secret value
# existing_secret: "new-value"

# Save and exit
```

### View Secrets

```bash
# Decrypt and view
sops -d secrets/secrets.yaml

# Or edit to view
sops secrets/secrets.yaml
```

### Remove Secret

```bash
# Edit secrets file
sops secrets/secrets.yaml

# Remove secret line
# old_secret: "value"  # Delete this line

# Save and exit
```

## Best Practices

### 1. Use Strong GPG Keys

```bash
# Generate 4096-bit RSA key
gpg --full-generate-key

# Set expiration (recommended)
gpg --edit-key YOUR_KEY_ID
> expire
> 1y  # or 2y, 5y, etc.
> save
```

### 2. Backup GPG Keys

```bash
# Export secret key
gpg --export-secret-keys --armor YOUR_KEY_ID > backup-key.asc

# Store securely (encrypted USB, password manager, etc.)
# NEVER commit this to Git!
```

### 3. Use Host-Specific Secrets

```yaml
# In secrets.yaml
# General secrets
database_password: "shared-password"

# Host-specific secrets
host_navi_token: "navi-only-token"
host_oryx_token: "oryx-only-token"
```

### 4. Rotate Secrets Regularly

```bash
# Schedule: Every 3-6 months

# Rotate secret
sops secrets/secrets.yaml
# Update: old_secret: "new-rotated-value"

# Deploy to all hosts
for host in navi oryx r730; do
  nixos-rebuild switch --flake .#$host
done
```

### 5. Limit Secret Access

Use host-specific secrets when possible

### 6. Document Secret Usage

```nix
# In configuration
sops.secrets = {
  # Jellyfin admin password
  # Used by: services.jellyfin.settings.admin_password_file
  # Rotated: 2026-01-15
  # Next rotation: 2026-07-15
  jellyfin_admin_password = {};
};
```

## Troubleshooting

### Problem: "No matching keys found"

**Cause**: GPG key not available or not in .sops.yaml

**Solution**:

```bash
# Check available keys
gpg --list-secret-keys

# Verify .sops.yaml includes your key
cat .sops.yaml

# Add key if missing
# Edit .sops.yaml and add key ID
```

### Problem: "Decryption failed"

**Cause**: Wrong passphrase or corrupted file

**Solution**:

```bash
# Try manual decryption
sops -d secrets/secrets.yaml

# Check GPG agent
gpg-agent --daemon

# Clear cache and retry
gpg-connect-agent reload
```

### Problem: Secret not available in NixOS

**Cause**: sops-nix not configured correctly

**Solution**:

```bash
# Check sops status
systemctl status sops-*

# Check secret path
ls -la /run/secrets/

# Verify configuration
nixos-option sops.secrets
```

## Security Considerations

### 1. Protect GPG Keys

- **Never commit** GPG private keys to Git
- Use strong passphrases
- Store backups securely
- Consider using hardware keys (YubiKey)

### 2. Limit Access

- Use host-specific secrets when possible
- Rotate keys if someone leaves the project
- Audit who has access to keys

### 3. Monitor Access

```bash
# Check Git history for secret changes
git log -- secrets/secrets.yaml

# Review who accessed secrets
git log --all --format='%H %an %ad' -- secrets/secrets.yaml
```

### 4. Incident Response

If a secret is compromised:

1. **Rotate immediately**: Change the secret value
2. **Revoke GPG key** if key is compromised
3. **Audit access**: Check who had access
4. **Update all hosts**: Deploy new secret
5. **Document incident**: Record what happened

---

**Last Updated**: August 2026
