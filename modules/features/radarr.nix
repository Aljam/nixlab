# Security: Radarr should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

{
  networking.proxyBackendPorts = [ 7878 ];

  services.radarr = {
    enable = true;
  };

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
