# modules/features/reverse-proxy-backends.nix
# Firewall rules for reverse proxy backends
# Only allows HAProxy gateway (192.168.1.1) to reach backend services
{ config, lib, pkgs, ... }:

let
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  # Backend services firewall rules
  # Only allow HAProxy gateway to reach these ports
  networking.firewall = {
    # Allow SSH from LAN (for initial setup)
    allowedTCPPorts = [ 22 ];

    # nftables rules to allow proxy IP to reach backend services
    extraInputRules = ''
      # Allow proxy IP to reach backend services
      ip saddr ${proxyIP} tcp dport { 3000, 5050, 5055, 8082, 8111, 9090, 9093, 9100, 13378, 8222, 8989, 8686, 8787, 7878, 9696, 8080, 8081, 8096 } accept comment "HAProxy backend access"
    '';
  };
}
