# modules/features/prowlarr.nix
# DRY: Generic *arr service module pattern
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP from flake.nix instead of hardcoding
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  services.prowlarr = {
    enable = true;
    # Security: Bind to localhost only (not 0.0.0.0)
    listenPort = 9696;
    bindAddress = "127.0.0.1";
  };

  # Firewall: Allow only from reverse proxy (not hardcoded IP)
  networking.firewall.extraInputRules = ''
    # Prowlarr: Only allow from reverse proxy
    ip saddr ${proxyIP} tcp dport 9696 accept
  '';
}
