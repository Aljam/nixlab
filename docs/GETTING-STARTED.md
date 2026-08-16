# Getting started

This guide covers the normal path from a fresh checkout to a validated NixOS deployment.

## Prerequisites

Install Nix with flakes enabled and ensure you can administer the target NixOS host. Review the repository’s setup and secret-management guidance before making changes.

## 1. Clone the repository

```sh
git clone https://github.com/Aljam/nixlab.git
cd nixlab
```

## 2. Inspect the flake

Start by listing the available outputs and checking the repository:

```sh
nix flake show
nix flake check
```

The repository currently contains host configurations for:

- `navi`
- `oryx`
- `r730`
- `r730xd`
- `r820`

Select the host that matches the machine you are configuring. Do not assume that a configuration intended for one hardware platform is suitable for another.

## 3. Review the configuration

Before building, inspect the selected host under `hosts/` and trace the modules it imports:

- `modules/features/` provides optional capabilities and services.
- `modules/hardware/` provides hardware-specific settings.
- `modules/roles/` provides reusable system roles.
- `users/` provides user configuration.
- `secrets/` provides encrypted secret inputs.

Check the relevant documentation for deployment, secrets, backups, alerts, and testing before applying changes.

## 4. Build without applying

Use a build first to catch evaluation and activation issues without changing the running system:

```sh
sudo nixos-rebuild build --flake .#<host>
```

Replace `<host>` with one of the available host names. Review warnings and errors before proceeding.

## 5. Validate

Run the flake checks and the applicable NixOS tests:

```sh
nix flake check
```

The test suite is in `tests/` and includes coverage for backup, firewall, security, and services. Follow [`TESTING-CHECKLIST.md`](TESTING-CHECKLIST.md) and [`../tests/README.md`](../tests/README.md) for the project-specific workflow.

## 6. Apply the configuration

When the build and checks are satisfactory:

```sh
sudo nixos-rebuild switch --flake .#<host>
```

Keep an existing working generation available until the new deployment has been verified.

## 7. Verify the result

After switching, verify the expected services, connectivity, logs, backups, and alerts. Use the [deployment checklist](DEPLOYMENT-CHECKLIST.md) and [backup and recovery guide](BACKUP-RECOVERY.md) for the post-deployment process.

## Troubleshooting

- If evaluation fails, run `nix flake check` and inspect the selected host’s module imports.
- If a secret cannot be decrypted, stop and follow [`SECRETS.md`](SECRETS.md); do not replace encrypted material with plaintext credentials.
- If a service fails after activation, inspect system logs and use the documented recovery procedure before making additional changes.
- If the target host is unclear, stop and confirm the hardware-to-host mapping rather than applying another host’s configuration.

## Next steps

- Read [`SETUP.md`](SETUP.md) for environment preparation.
- Read [`ARCHITECTURE.md`](ARCHITECTURE.md) to understand composition.
- Read [`ROLES.md`](ROLES.md) before adding or changing reusable roles.
- Read [`SECRETS.md`](SECRETS.md) before handling encrypted configuration.
- Follow [`DEPLOYMENT-CHECKLIST.md`](DEPLOYMENT-CHECKLIST.md) for production changes.
