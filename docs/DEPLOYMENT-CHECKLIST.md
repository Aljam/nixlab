# Deployment Checklist

Use this checklist when deploying or changing a nixlab host.

## Before changing configuration

- [ ] Confirm the target host and its flake output.
- [ ] Review the relevant role and feature modules.
- [ ] Confirm that `DEFAULT_SERVER` and other shared values come from host settings.
- [ ] Identify new persistent data, database requirements, ports, firewall rules, and reverse-proxy exposure.
- [ ] Confirm that all credentials and bootstrap files are encrypted or supplied out-of-band.

## Validate the change

- [ ] Run `nix flake check`.
- [ ] Build or test the target host:

  ```bash
  sudo nixos-rebuild test --flake .#<host>
  ```

- [ ] Review the evaluated configuration for service enablement, ports, and firewall rules.
- [ ] Confirm that no plaintext secret, private key, or generated credential appears in the diff.
- [ ] Check that database declarations match the consuming services.

## Service-specific checks

### PostgreSQL and webscraper database

- [ ] Confirm PostgreSQL is enabled on the target host.
- [ ] Confirm the dedicated `webscraper` database is declared when the webscraper workload is deployed.
- [ ] Confirm database ownership and credentials are correct.
- [ ] Verify persistent PostgreSQL storage is included in backups.

### pgAdmin

- [ ] Confirm the initial email uses `initialEmail`.
- [ ] Confirm the initial password is supplied with `initialPasswordFile` and is not committed as plaintext.
- [ ] Confirm pgAdmin uses the configured port `5050`.
- [ ] Confirm the firewall allows the intended pgAdmin port only on the intended network boundary.
- [ ] Confirm the systemd listen override is required for the chosen access path.
- [ ] Log in once, change the bootstrap password, and verify remote access only if explicitly intended.

### Vaultwarden

- [ ] Confirm Vaultwarden uses port `8222`.
- [ ] Confirm the service is reachable only through the intended trusted network or reverse proxy.
- [ ] Confirm TLS, proxy headers, secret values, and backup coverage before production use.

## Rollout

- [ ] Apply a test activation first:

  ```bash
  sudo nixos-rebuild test --flake .#<host>
  ```

- [ ] Check `systemctl --failed` and relevant service status.
- [ ] Verify listening sockets and firewall behavior from an approved client.
- [ ] Verify Grafana, pgAdmin, Vaultwarden, and other changed services as applicable.
- [ ] Confirm the webscraper application can connect to PostgreSQL if it is deployed.
- [ ] Apply the persistent configuration only after validation:

  ```bash
  sudo nixos-rebuild switch --flake .#<host>
  ```

- [ ] Record the deployed revision and any host-specific follow-up.

## After deployment

- [ ] Confirm backups complete successfully.
- [ ] Confirm monitoring and alerting remain healthy.
- [ ] Confirm new ports are documented and not unintentionally Internet-facing.
- [ ] Update this checklist or the architecture guide if the operational behavior changed.
