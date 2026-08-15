# Tests

## CI checks

The security workflow performs two checks:

- Gitleaks scans the working tree and the complete Git history. The checkout uses `fetch-depth: 0`, so deleted or superseded secrets are included in the scan. Findings are redacted in CI output.
- `nix flake check --show-trace` evaluates the repository's flake checks.

Run the secret scan locally with:

```sh
gitleaks detect --source . --redact --verbose
```

Run the Nix checks locally with:

```sh
nix flake check --show-trace
```

## Configuration assertions

`security.nix` contains reusable NixOS assertions for baseline security policy. Import it from a test configuration or from the appropriate host test when the host configuration is available. Keep assertions focused on invariants, such as requiring SSH keys instead of passwords and ensuring privileged services do not run with unsafe defaults.

Do not place real credentials, tokens, private keys, or decrypted SOPS output in tests or fixtures. If a historical secret is found, revoke or rotate it even after removing it from Git history.
