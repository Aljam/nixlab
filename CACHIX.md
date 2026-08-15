# Cachix Binary Cache Setup

This document describes how to set up and use Cachix for faster builds in nixlab.

## What is Cachix?

Cachix is a binary cache service for Nix that:
- Stores build artifacts (packages, system configurations)
- Shares builds across machines and CI/CD pipelines
- Speeds up builds by downloading pre-built binaries instead of compiling

## Quick Start

### 1. Install Cachix CLI

```bash
# Install via official installer
bash <(curl -L https://cachix.org/install.sh)
```

### 2. Create Cachix Cache (Web Interface)

1. Go to https://app.cachix.org
2. Sign in with GitHub
3. Click "Create cache"
4. Enter cache name: `nixlab`
5. Choose visibility (private recommended)
6. Click "Create"

### 3. Configure Nix to Use Cachix

**Option A: Automatic (Recommended)**

```bash
# This adds the cache to your nix.conf
cachix use nixlab
```

**Option B: Manual Configuration**

Add to `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```conf
substituters = https://nixlab.cachix.org https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nixlab.cachix.org-1:YOUR_PUBLIC_KEY=
```

Get your public key from: https://app.cachix.org → Your cache → Settings

### 4. Get Authentication Token (for CI/CD)

1. Go to https://app.cachix.org
2. Select your cache: `nixlab`
3. Click "Settings"
4. Under "Authentication", click "Create token"
5. Copy the token
6. Add to GitHub secrets as `CACHIX_AUTH_TOKEN`

## CI/CD Integration

### GitHub Actions

The repository includes `.github/workflows/cachix.yml` which:
- Runs on every push to main and PR
- Builds all host configurations
- Populates the Cachix cache automatically

#### Required Secrets

Add to GitHub repository settings → Secrets → Actions:

- `CACHIX_AUTH_TOKEN`: Your Cachix authentication token from step 4

### Manual Cache Population

```bash
# Build all hosts
for host in navi oryx r730 r730xd r820; do
  nix build .#nixosConfigurations.$host.config.system.build.toplevel \
    --no-link
  
  # Upload to Cachix
  cachix push nixlab result
  
  rm result
done
```

## Usage

### Pull from Cache

```bash
# Nix will automatically use Cachix if configured
nixos-rebuild switch --flake .#hostname
```

### Push to Cache

```bash
# Build locally
nix-build -A nixosConfigurations.navi.config.system.build.toplevel

# Push to Cachix
cachix push nixlab result
```

## Cache Settings

Recommended settings in Cachix dashboard:

- **Public**: No (private cache)
- **Upload from**: Anyone with write access
- **Download from**: Anyone with the public key
- **Retention**: Keep all versions

## Best Practices

### 1. Use in Development

```bash
# Add to your shell
export CACHIX_NAME="nixlab"
cachix watch-exec $CACHIX_NAME -- nixos-rebuild switch --flake .#hostname
```

### 2. Build in CI

Always build in CI to populate the cache:

```yaml
- name: Build and cache
  run: |
    nix build .#nixosConfigurations.navi.config.system.build.toplevel
    cachix push nixlab result
```

### 3. Monitor Cache Usage

```bash
# Check cache stats (via web UI)
# https://app.cachix.org → Your cache → Stats
```

## Troubleshooting

### Cache Not Being Used

**Problem**: Nix is building from source instead of using cache

**Solution**:
```bash
# Verify cache configuration
nix show-config | grep substituters

# Check trusted keys
nix show-config | grep trusted-public-keys

# Re-add cache
cachix use nixlab
```

### Authorization Errors

**Problem**: "Permission denied" when pushing

**Solution**:
1. Go to https://app.cachix.org
2. Create a new token
3. Update `CACHIX_AUTH_TOKEN` secret in GitHub

### Cache Miss

**Problem**: Package not found in cache

**Solution**:
```bash
# Build locally
nix-build -A your-package

# Push to cache
cachix push nixlab result
```

## Cost Optimization

Cachix free tier includes:
- 5 GB storage
- 50 GB bandwidth/month

To optimize:

1. **Cache only what's needed**:
   - System configurations
   - Common packages
   - Don't cache everything

2. **Use cache.nixos.org**:
   - Most packages are already there
   - Only cache your custom builds

## Resources

- [Cachix App](https://app.cachix.org)
- [Cachix Documentation](https://docs.cachix.org/)
- [Cachix Pricing](https://cachix.org/pricing)
- [Cachix Install](https://cachix.org/)

---

**Last Updated**: August 2026
