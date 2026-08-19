# Secrets Management

This document describes the SOPS-based secret management system used in nixlab.

## Overview

nixlab uses **SOPS (Secrets OPerationS)** with **age** encryption to manage sensitive data like API keys, passwords, and certificates. Secrets are encrypted before committing to Git and automatically decrypted during NixOS activation via the `sops-nix` module.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Plaintext      │     │  SOPS encrypt    │     │  Encrypted      │
│  secret.yaml    │────▶│  with age keys   │────▶│  secret.enc.yaml│
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                                                          │ Git commit
                                                          ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  NixOS service  │◀────│  sops-nix        │◀────│  Decrypted at   │
│  (postgresql)   │     │  integration     │     │  activation     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Key Management

### age Keys

Each administrator and host has an age key pair:

```bash
# Generate age key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/admin-key.txt
# Output: age1... (public key)
```

### Key Hierarchy

```
Admin Keys (humans)
├── aljam.age
├── admin2.age
└── ...

Host Keys (machines)
├── r820.age
├── r730.age
├── r730xd.age
├── navi.age
└── oryx.age
```

## SOPS Configuration

### `.sops.yaml`

```yaml
# .sops.yaml
creation_rules:
  # Host-specific secrets
  - path_regex: secrets/hosts/[^/]+\.yaml$
    age: >-
      age1admin1,
      age1admin2,
      age1r820,
      age1r730,
      age1r730xd,
      age1navi,
      age1oryx

  # Shared secrets (all hosts + admins)
  - path_regex: secrets/shared/.*\.yaml$
    age: >-
      age1admin1,
      age1admin2,
      age1r820,
      age1r730,
      age1r730xd,
      age1navi,
      age1oryx
```

## Creating Secrets

### 1. Create Plaintext Secret

```yaml
# secrets/shared/database.yaml
postgres:
  superuser: postgres
  password: "super-secret-password"
  replication_password: "replica-password"
```

### 2. Encrypt with SOPS

```bash
# Encrypt
sops encrypt secrets/shared/database.yaml > secrets/shared/database.enc.yaml

# Verify
sops decrypt secrets/shared/database.enc.yaml

# Remove plaintext
rm secrets/shared/database.yaml

# Add to git
git add secrets/shared/database.enc.yaml
git commit -m "Add database secrets"
```

### 3. Use in NixOS Configuration

```nix
# modules/roles/database/default.nix
{
  sops.secrets.postgres-password = {
    sopsFile = ../../secrets/shared/database.yaml;
    neededForUsers = true;
  };
  
  services.postgresql = {
    enable = true;
    passwordFile = config.sops.secrets.postgres-password.path;
  };
}
```

## Accessing Secrets

### Decrypt for Inspection

```bash
# Decrypt to stdout
sops decrypt secrets/shared/database.enc.yaml

# Decrypt to file
sops decrypt secrets/shared/database.enc.yaml > /tmp/database.yaml

# Edit encrypted file (opens in editor, re-encrypts on save)
sops secrets/shared/database.enc.yaml
```

## Security Best Practices

### 1. Never Commit Plaintext

```bash
# WRONG: Commit plaintext
git add secrets/shared/database.yaml  # ❌

# RIGHT: Encrypt first
sops encrypt secrets/shared/database.yaml > secrets/shared/database.enc.yaml
git add secrets/shared/database.enc.yaml  # ✅
```

### 2. Use .gitignore

```gitignore
# .gitignore
# Never commit plaintext secrets
secrets/**/*.yaml
!secrets/**/*.enc.yaml
```

### 3. Rotate Keys Regularly

```bash
# Rotate admin keys annually
# Rotate host keys when decommissioning hardware
```

## Troubleshooting

### SOPS Decryption Fails

```bash
# Error: "no keys found in auth info"
# Solution: Verify your age key is in ~/.config/sops/age/keys.txt
cat ~/.config/sops/age/keys.txt

# Error: "could not decrypt data"
# Solution: Ensure your key is in .sops.yaml for this secret
cat .sops.yaml | grep -A 5 "path_regex"
```

---

**Last Updated**: August 2026