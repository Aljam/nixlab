# Cachix Binary Cache Setup

This document describes how to set up and use Cachix for faster builds in nixlab.

## What is Cachix?

Cachix is a binary cache service for Nix that:
- Stores build artifacts (packages, system configurations)
- Shares builds across machines and CI/CD pipelines
- Speeds up builds by downloading pre-built binaries instead of compiling

## Quick Start

### 1. Install Cachix

**Option A: Official Installer (Recommended)**

```bash
# Install via official installer
bash <(curl -L https://cachix.org/install.sh)
```

**Option B: From nixpkgs (if available)**

```bash
# If you have nixpkgs configured
nix-env -iA cachix
```

**Option C: Nix shell (temporary)**

```bash
# Use in a temporary shell
nix-shell -p cachix
```

### 2. Create Cachix Cache

```bash
# Login to Cachix
cachix login

# Create a new cache (replace 'nixlab' with your cache name)
cachix create nixlab
```

### 3. Configure Nix to Use Cachix

**Option A: Automatic (Recommended)**

```bash
# Automatically configure nix.conf
cachix use nixlab
```

**Option B: Manual Configuration**

Add to `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```conf
substituters = https://nixlab.cachix.org https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nixlab.cachix.org-1:YOUR_CACHE_KEY=
```

### 4. Add Authentication Token (for pushing)

```bash
# Get your auth token from https://app.cachix.org
# Add to environment
export CACHIX_AUTH_TOKEN="your-token-here"
```

## CI/CD Integration

### GitHub Actions

The repository includes `.github/workflows/cachix.yml` which:
- Runs on every push to main and PR
- Builds all host configurations
- Populates the Cachix cache automatically

#### Required Secrets

Add to GitHub repository settings → Secrets → Actions:

- `CACHIX_AUTH_TOKEN`: Your Cachix authentication token

### Manual Cache Population

```bash
# Build and cache all hosts
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

## Cache Configuration

### flake.nix

The flake includes Cachix configuration:

```nix
{
  nix = {
    settings = {
      substituters = ["https://nixlab.cachix.org"];
      trusted-public-keys = ["nixlab.cachix.org-1:YOUR_KEY="];
    };
  };
}
```

### Cache Settings

Recommended settings in Cachix dashboard:

- **Public**: No (private cache)
- **Upload from**: Anyone with write access
- **Download from**: Anyone with the public key
- **Retention**: Keep all versions

## Best Practices

### 1. Cache Frequently Built Packages

```bash
# Cache common packages
nix-env -iA nixpkgs.git
nix-env -iA nixpkgs.vim
nix-env -iA nixpkgs.htop

# Push to cache
cachix push nixlab /nix/store/*-git-*
```

### 2. Build in CI

Always build in CI to populate the cache:

```yaml
- name: Build and cache
  run: |
    nix build .#nixosConfigurations.navi.config.system.build.toplevel
    cachix push nixlab result
```

### 3. Use Cache in Development

```bash
# Before starting work
nix-shell -p cachix

# Use cache
export CACHIX_NAME="nixlab"
cachix watch-exec $CACHIX_NAME -- nixos-rebuild switch --flake .#hostname
```

### 4. Monitor Cache Usage

```bash
# Check cache stats
cachix show nixlab

# List cached paths
cachix list-paths nixlab
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

# Manually add cache
cachix use nixlab
```

### Authorization Errors

**Problem**: "Permission denied" when pushing

**Solution**:
```bash
# Refresh auth token
cachix authtoken

# Verify token
env | grep CACHIX
```

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

3. **Clean old versions**:
   ```bash
   # Remove old paths from cache
   cachix delete-path nixlab /nix/store/old-path
   ```

## Alternatives

### Self-Hosted Options

1. **Attic** - Modern binary cache
   ```bash
   bash <(curl -L https://github.com/zhaofengli/attic/releases/latest/download/install.sh)
   ```

2. **Nix Binary Cache** - Official NixOS cache server
   ```bash
   nix-env -iA nixpkgs.nix-binary-cache
   ```

3. **S3 + nix-serve**
   ```bash
   nix-env -iA nixpkgs.nix-serve
   ```

## Resources

- [Cachix Documentation](https://docs.cachix.org/)
- [Cachix Pricing](https://cachix.org/pricing)
- [Cachix Install](https://cachix.org/)
- [Nix Binary Cache](https://nix.dev/manual/nix/stable/command-ref/conf-file.html#conf-substituters)

---

**Last Updated**: August 2026
