# modules/features/lidarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

{
  services.lidarr = {
    enable = true;
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
}
