# modules/features/vaultwarden.nix
# Security: Vaultwarden should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  # Vaultwarden secrets
  sops.secrets."vaultwarden-admin-token" = {};

  services.vaultwarden = {
    enable = true;
    config = {
      rocketAddress = bindAddr;
      rocketPort = 8222;
      domain = "https://vault.${config.networking.domain}";
      signupsAllowed = false;
      adminTokenFile = config.sops.secrets."vaultwarden-admin-token".path;
      adminRateLimitSeconds = 300;
      adminRateLimitMaxBurst = 10;
    };
  };
}
