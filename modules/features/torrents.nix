# modules/features/torrents.nix
# Security: Torrent service should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  # Torrent service configuration (qbittorrent/transmission/etc.)
  # Security: Bind to host IP for HAProxy access (or localhost if no host IP)
  # Configure your torrent service to use bindAddr
  # Example for qbittorrent:
  # services.qbittorrent = {
  #   enable = true;
  #   openFirewall = false;
  #   port = 8080;
  #   webui.address = bindAddr;
  #   webui.port = 8080;
  # };

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
