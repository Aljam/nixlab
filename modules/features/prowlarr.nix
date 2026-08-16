# modules/features/prowlarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

{
  services.prowlarr = {
    enable = true;
    # Security: Bind to localhost only (not 0.0.0.0)
    listenPort = 9696;
    bindAddress = "127.0.0.1";
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
}
