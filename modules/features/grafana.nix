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
        # Use sops secret for grafana admin password
        admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
        # Use sops secret for grafana secret key
        secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
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
