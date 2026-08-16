# modules/features/radarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

{
  services.radarr = {
    enable = true;
    # Security: Bind to localhost only (not 0.0.0.0)
    listenPort = 7878;
    bindAddress = "127.0.0.1";
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
  # No need for per-module extraInputRules
}
