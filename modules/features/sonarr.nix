# modules/features/sonarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    # Security: Bind to localhost only (not 0.0.0.0)
    listenPort = 8989;
    bindAddress = "127.0.0.1";
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
}
