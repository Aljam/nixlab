# modules/features/prowlarr.nix
# Security: Prowlarr should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.prowlarr = {
    enable = true;
    # Security: Bind to host IP for HAProxy access (or localhost if no host IP)
    listenAddress = bindAddr;
    port = 9696;
  };

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
