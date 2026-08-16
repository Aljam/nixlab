# modules/features/radarr.nix
# Security: Radarr should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.radarr = {
    enable = true;
    # Security: Bind to host IP for HAProxy access (or localhost if no host IP)
    listenAddress = bindAddr;
    port = 7878;
  };

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
