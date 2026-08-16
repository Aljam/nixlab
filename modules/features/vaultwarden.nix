# modules/features/vaultwarden.nix
# Security: Vaultwarden should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  # Vaultwarden configuration
  services.vaultwarden = {
    enable = true;
    config = {
      # Security: Bind to host IP for HAProxy access (or localhost if no host IP)
      address = bindAddr;
      port = 8000;
      domain = "https://vault.${config.networking.domain}";
      # Use sops for admin token
      admin_token = "$__file{${config.sops.secrets."vaultwarden-admin-token".path}}";
    };
  };

  # Declare secret
  sops.secrets."vaultwarden-admin-token" = {};

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
