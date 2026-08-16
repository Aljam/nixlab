# modules/features/grafana.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = bindAddr;
        http_port = 3000;
        domain = "grafana.${config.networking.domain}";
        root_url = "https://grafana.${config.networking.domain}/";
      };
      security = {
        admin_user = "aljam";
        admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
        secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
      };
    };
    # Disable default provisioning
    provision = {
      enable = false;
    };
  };

  sops.secrets."grafana-admin-password" = {};
  sops.secrets."grafana-secret-key" = {};
}
