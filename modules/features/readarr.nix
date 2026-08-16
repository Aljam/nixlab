# modules/features/readarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

{
  services.readarr = {
    enable = true;
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
}
