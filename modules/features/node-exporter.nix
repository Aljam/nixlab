# modules/features/node-exporter.nix
# DRY: Use shared proxy IP from flake.nix instead of hardcoding 192.168.1.1
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP from flake.nix
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    # Optional: Bind to localhost if only proxy needs access
    # openFirewall = false; # We'll handle firewall manually below
  };

  # Firewall: Allow only from reverse proxy (not hardcoded IP)
  networking.firewall.extraInputRules = ''
    # Node exporter: Only allow from reverse proxy
    ip saddr ${proxyIP} tcp dport 9100 accept
  '';
}
