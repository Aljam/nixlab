# modules/features/vaultwarden.nix
# Security: Bind to localhost only - reverse proxy provides external access
{ config, lib, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    config = {
      # Security: Bind to localhost only (not 0.0.0.0)
      address = "127.0.0.1";
      port = 8000;
      domain = "https://vault.${config.networking.domain}";
      # Security headers and proper proxy configuration
      webVaultEnabled = true;
      notificationsEnabled = true;
      # Admin interface (also localhost only)
      adminToken = "$__file{${config.sops.secrets."vaultwarden-admin-token".path}}";
      adminUrl = "/admin";
    };
  };

  # Firewall: No direct LAN access - reverse proxy only
  # networking.firewall.allowedTCPPorts removed - handled by reverse-proxy-backends
}
