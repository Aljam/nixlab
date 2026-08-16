# modules/features/grafana.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  sops.secrets."grafana-admin-password" = {
    owner = "grafana";
    group = "grafana";
    mode = "0640";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = bindAddr;
        http_port = 3000;
      };
      security = {
        admin_password = "$__file{/run/secrets/grafana-admin-password}";
        secret_key = "$__file{/run/secrets/grafana-secret-key}";
      };
    };
  };

  # Generate secret key if not exists
  sops.secrets."grafana-secret-key" = {
    owner = "grafana";
    group = "grafana";
    mode = "0640";
  };

  # Ensure grafana service can read the secrets
  systemd.services.grafana = {
    serviceConfig = {
      SupplementaryGroups = [ "sops" ];
    };
  };
}
