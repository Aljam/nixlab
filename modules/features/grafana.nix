# modules/features/grafana.nix
# Security: Bind to localhost only - reverse proxy provides external access
{ config, lib, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Security: Bind to localhost only (not 0.0.0.0)
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.${config.networking.domain}";
        root_url = "https://grafana.${config.networking.domain}";
      };
      security = {
        # Use sops secrets from secrets.yaml
        admin_password = config.sops.secrets."grafana-admin-password".path;
        secret_key = config.sops.secrets."grafana-secret-key".path;
      };
      users = {
        allow_sign_up = false;
        allow_org_create = false;
      };
    };
  };

  # Firewall: No direct LAN access needed - reverse proxy only
  # networking.firewall.allowedTCPPorts removed - handled by reverse-proxy-backends
}
