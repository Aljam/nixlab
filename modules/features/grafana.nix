# modules/features/grafana.nix
# Security: Grafana should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  # Grafana configuration
  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Security: Bind to host IP for HAProxy access (or localhost if no host IP)
        http_addr = bindAddr;
        http_port = 3000;
        domain = "grafana.${config.networking.domain}";
        root_url = "https://grafana.${config.networking.domain}/";
      };
      security = {
        admin_user = "aljam";
        # Use sops for initial password
        admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
        secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
      };
    };
  };

  # Declare secrets
  sops.secrets."grafana-admin-password" = {};
  sops.secrets."grafana-secret-key" = {};

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
