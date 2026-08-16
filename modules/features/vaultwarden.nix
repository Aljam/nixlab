# modules/features/vaultwarden.nix
# Security: Vaultwarden should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  # Vaultwarden secrets
  sops.secrets."vaultwarden-admin-token" = {};
  sops.secrets."vaultwarden-secret-key" = {};
  sops.secrets."vaultwarden-env" = {};

  services.vaultwarden = {
    enable = true;
    # Security: Bind to host IP for HAProxy access (or localhost if no host IP)
    config = {
      rocketAddress = bindAddr;
      rocketPort = 8222;
      domain = "https://vault.${config.networking.domain}";
      signupsAllowed = false;
      adminTokenFile = config.sops.secrets."vaultwarden-admin-token".path;
      adminRateLimitSeconds = 300;
      adminRateLimitMaxBurst = 10;
    };
    # Use SOPS secret for environment variables (ADMIN_TOKEN, etc.)
    environmentFile = config.sops.secrets."vaultwarden-env".path;
  };

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
