# Deployment Checklist

Use this checklist when deploying or changing a nixlab host.

## Before changing configuration

- [ ] Confirm the target host and flake output.
- [ ] Review the target host's hardware profile, roles, and enabled features.
- [ ] Confirm shared values such as `DEFAULT_SERVER` come from host settings.
- [ ] Identify new persistent data, database requirements, ports, firewall rules, and reverse-proxy exposure.
- [ ] Confirm credentials and bootstrap files are encrypted or supplied out-of-band.
- [ ] Check whether the change requires documentation, backup, or alerting updates.

## Validate the configuration

- [ ] Run `nix flake check`.
- [ ] Test the target host:

  ```bash
  sudo nixos-rebuild test --flake .#<host>
  ```

- [ ] Review the evaluated configuration for service enablement, ports, firewall rules, and proxy exposure.
- [ ] Confirm no plaintext secret, private key, token, password, or generated credential appears in the diff.
- [ ] Confirm service settings and host settings agree.
- [ ] Confirm persistent data paths are covered by the backup plan.

## Service checks

### PostgreSQL and Grafana

- [ ] Confirm PostgreSQL is enabled where required.
- [ ] Confirm required databases, roles, ownership, and credentials are declared.
- [ ] Confirm Grafana's database connection settings match PostgreSQL.
- [ ] Verify PostgreSQL storage and application data are included in backups.

### pgAdmin

- [ ] Confirm the initial email uses `initialEmail`.
- [ ] Confirm the initial password is supplied through `initialPasswordFile` and is not plaintext.
- [ ] Confirm pgAdmin uses port `5050`.
- [ ] Confirm the firewall allows port `5050` only on the intended network boundary.
- [ ] Confirm the systemd listen override is required for the chosen access path.
- [ ] Log in once, change the bootstrap password, and verify remote access only if explicitly intended.

### Vaultwarden

- [ ] Confirm Vaultwarden uses port `8222`.
- [ ] Confirm it is reachable only through the intended trusted network or reverse proxy.
- [ ] Confirm TLS, proxy headers, secret values, and backup coverage before production use.

### Monitoring and media services

- [ ] Confirm changed services are enabled through the intended role or feature module.
- [ ] Verify Grafana, Prometheus, node exporter, alerting, and media services as applicable.
- [ ] Confirm service data directories are persistent and backed up where required.

## Rollout

- [ ] Apply a temporary test activation first:

  ```bash
  sudo nixos-rebuild test --flake .#<host>
  ```

- [ ] Check `systemctl --failed` and the status of changed services.
- [ ] Verify listening sockets and firewall behavior from an approved client.
- [ ] Verify reverse-proxy routes and TLS if proxy exposure changed.
- [ ] Confirm monitoring and alerts remain healthy.
- [ ] Apply the persistent configuration only after validation:

  ```bash
  sudo nixos-rebuild switch --flake .#<host>
  ```

- [ ] Record the deployed revision and any host-specific follow-up.

## After deployment

- [ ] Confirm backups complete successfully.
- [ ] Confirm monitoring and alerting remain healthy.
- [ ] Confirm new ports are documented and not unintentionally Internet-facing.
- [ ] Confirm secrets and bootstrap credentials are not exposed in logs or process arguments.
- [ ] Update the README or relevant guide if the operational behavior changed.
