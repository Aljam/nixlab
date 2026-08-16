# modules/features/radarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP from flake.nix instead of hardcoding
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  services.radarr = {
    enable = true;
    # Security: Bind to localhost only (not 0.0.0.0)
    listenPort = 7878;
    bindAddress = "127.0.0.1";
  };

  # Firewall: Allow only from reverse proxy (not hardcoded IP)
  networking.firewall.extraInputRules = ''
    # Radarr: Only allow from reverse proxy
    ip saddr ${proxyIP} tcp dport 7878 accept
  '';
}
