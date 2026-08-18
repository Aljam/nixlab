# Secrets Management

This document describes how to manage passwords, API keys, certificates, and other sensitive values in nixlab using SOPS, age, and sops-nix.

## Overview

nixlab stores encrypted secret files in Git. SOPS encrypts the data key to configured age recipients, while sops-nix decrypts declared secrets on the target host during activation.

Encrypted files are safe to version-control only when they contain no plaintext secrets and the corresponding private keys remain outside the repository.

## Repository layout

```text
secrets/
└── secrets.yaml       # Encrypted SOPS file

.sops.yaml             # SOPS creation rules and age recipients
```

The repository's `.sops.yaml` is the source of truth for which age recipients can decrypt newly encrypted files. Review it before adding or rotating secrets.

## Key model

The repository uses age recipients rather than GPG key IDs.

- The operator's age identity allows an administrator to edit and recover secrets.
- Host age recipients allow selected NixOS machines to decrypt secrets during activation.
- On hosts, sops-nix can use the SSH host Ed25519 private key configured by `sops.age.sshKeyPaths` as a decryption identity.
- Age recipient strings and SSH public keys are not secret; private age identities and SSH host private keys are.

Treating an SSH host key as an age identity is convenient, but it means rotating or losing that host key affects both SSH host identity and secret recovery. Document and test the recovery path before rotating host keys.

## Prerequisites

Install SOPS and age through a temporary Nix shell or your preferred package configuration:

```bash
nix-shell -p sops age
```

The repository may also provide these tools through its development shell or system packages.

Verify the tools:

```bash
sops --version
age --version
```

## Editing secrets

Edit the encrypted file with SOPS:

```bash
sops secrets/secrets.yaml
```

SOPS decrypts the file into the editor and re-encrypts it when the editor exits. Add only the values required by the configuration, for example:

```yaml
database_password: "replace-me"
api_key: "replace-me"
cert_pem: |
  -----BEGIN CERTIFICATE-----
  replace-me
  -----END CERTIFICATE-----
```

Inspect a decrypted copy only when necessary:

```bash
sops -d secrets/secrets.yaml
```

Do not redirect decrypted output into a tracked file, shell history, CI log, or chat transcript.

## Adding a new secret

1. Confirm the secret belongs in the existing file and that all current recipients should have access.
2. Edit the encrypted file with `sops secrets/secrets.yaml`.
3. Declare the secret in the relevant NixOS module with `sops.secrets.<name>`.
4. Reference the generated `/run/secrets/<name>` path from the service configuration.
5. Build the affected host and deploy it.
6. Verify the service without printing the secret value.

Example:

```nix
{
  sops.secrets.api_key = {};

  environment.variables.API_KEY_FILE = config.sops.secrets.api_key.path;
}
```

Secret values should be consumed through files or service-specific secret-file options. Avoid interpolating plaintext secret values into Nix expressions or command lines.

## Recipient changes

When adding or removing a recipient, update `.sops.yaml` and re-encrypt the file so its data key is wrapped for the new recipient set.

Before changing recipients, ensure you still have a working administrator identity and a tested recovery path. A recipient listed in `.sops.yaml` does not automatically rewrite existing encrypted files.

After changing the policy:

```bash
sops updatekeys secrets/secrets.yaml
```

Review the resulting diff. It should change encrypted metadata, not expose plaintext.

## Backups and recovery

Back up the administrator age identity outside Git. Store it in an encrypted password manager, offline encrypted storage, or another protected recovery location.

Never commit an age identity file, SSH host private key, decrypted secrets file, or plaintext backup.

If a host loses its SSH host key or cannot decrypt secrets:

1. Confirm an administrator identity can still decrypt the file.
2. Restore or replace the host key using your documented host recovery procedure.
3. Ensure the replacement host recipient is present in `.sops.yaml`.
4. Run `sops updatekeys secrets/secrets.yaml` if the encrypted file needs updated recipient metadata.
5. Rebuild and activate the host.
6. Verify only the intended secret paths are present under `/run/secrets`.

If all administrator identities and all authorized host identities are lost, the encrypted file cannot be recovered. Maintain at least one protected administrator backup.

## Deployment

Build before switching when practical:

```bash
nix flake check --show-trace
nix build ".#nixosConfigurations.r820.config.system.build.toplevel" --no-link --print-build-logs
```

Deploy the affected host using the repository's normal procedure. After activation, check the secret service and paths without displaying values:

```bash
systemctl status sops-nix
sudo find /run/secrets -maxdepth 1 -type f -printf '%f\n'
```

## Rotation

Rotate the underlying service credential first, then update the encrypted value and redeploy the affected hosts:

```bash
sops secrets/secrets.yaml
nix flake check --show-trace
```

Rotate immediately if a secret was committed in plaintext, exposed in logs, copied into an insecure backup, or accessible to an unauthorized host. Encryption in Git does not make a previously exposed plaintext value safe.

## Troubleshooting

### No matching age identity

Check that the administrator identity is available locally or that the host's configured SSH private key exists and is readable by the expected activation path. Do not paste the private key into the repository or a support request.

### Recipient or key mismatch

Inspect the public recipient policy:

```bash
cat .sops.yaml
```

Then verify the encrypted file has been updated after recipient changes:

```bash
sops updatekeys secrets/secrets.yaml
```

### Secret missing after activation

Check the NixOS configuration declares the secret and the activation service ran:

```bash
systemctl status sops-nix
sudo ls -la /run/secrets
```

Inspect service logs without printing secret contents:

```bash
journalctl -u sops-nix -b
```

### Service cannot read a secret

Check the declared owner, group, and mode in `sops.secrets.<name>`. The service account must be able to read the generated file, but the file should not be world-readable.

## Security checklist

- Commit encrypted SOPS files only.
- Never commit plaintext secrets, age identities, SSH host private keys, or decrypted backups.
- Keep at least one protected administrator identity backup.
- Give host recipients only the access they need; split secret files when trust boundaries differ.
- Review `.sops.yaml` before adding recipients.
- Rotate service credentials after exposure.
- Avoid printing decrypted output in CI logs, shells, or chat.
- Test host-key-loss recovery before relying on SSH host keys as age identities.

## Incident response

If a secret may be compromised:

1. Rotate the underlying service credential immediately.
2. Re-encrypt and deploy the replacement value.
3. Remove plaintext copies from working directories, logs, and backups where possible.
4. Review Git history and access logs.
5. Remove or replace compromised age or SSH identities.
6. Update `.sops.yaml` and run `sops updatekeys`.
7. Rebuild affected hosts and document the incident.

---

**Last updated:** August 2026
