# Cachix

This repository uses Cachix as an optional binary cache for the selected NixOS system closure.

## Cache policy

The GitHub Actions Cachix workflow intentionally builds and pushes only:

```text
.#nixosConfigurations.navi.config.system.build.toplevel
```

It does not use a broad `watch-exec` around the build and does not upload unrelated CI outputs. The workflow first evaluates the selected system closure, records its store path, and then pushes that path explicitly.

To cache a different host, change the host output in `.github/workflows/cachix.yml`. To cache an additional output, add a separate explicit build and push step for that output rather than widening the existing workflow.

## GitHub Actions setup

The workflow requires a repository secret named `CACHIX_AUTH_TOKEN` with permission to push to the `nixlab` cache.

The workflow runs on pushes to `main` and can also be started manually. It currently caches the `navi` system closure; update the workflow if another host should be the release target.

## Local setup

Install the Cachix CLI and authenticate:

```bash
cachix authtoken <token>
cachix use nixlab
```

Use the cache as a substituter when building or deploying:

```bash
nix build \
  --substituters 'https://nixlab.cachix.org https://cache.nixos.org' \
  .#nixosConfigurations.navi.config.system.build.toplevel
```

## Explicit local push

Build a specific output and push only its resulting closure:

```bash
nix build .#nixosConfigurations.navi.config.system.build.toplevel --no-link --print-out-paths > result
cachix push nixlab < result
```

Avoid piping broad build commands or entire development environments into `cachix push` unless those outputs are intentionally part of the cache policy.

## Troubleshooting

### Authentication fails

Confirm that `CACHIX_AUTH_TOKEN` exists, is valid, and has push permission for the `nixlab` cache.

### A build is not served from Cachix

Check that the exact output was explicitly pushed, that the cache is listed as a substituter, and that the local Nix configuration trusts the cache key.

### The cache is still growing unexpectedly

Inspect workflow logs for additional `nix build`, `cachix push`, or `watch-exec` steps. Keep uploads limited to named system closures and remove accidental pushes of development shells or intermediate outputs.
