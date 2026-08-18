# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

{
  networking.proxyBackendPorts = [ 8686 ];

  services.lidarr = {
    enable = true;
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
}
