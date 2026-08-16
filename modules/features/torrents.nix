# modules/features/torrents.nix
# Security: Torrent service should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  # qBittorrent service
  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    port = 8080;
    webui = {
      address = bindAddr;
      port = 8080;
    };
  };

  # qBittorrent Web UI (qbweb) - alternative web interface
  services.qbittorrent-webui = {
    enable = true;
    openFirewall = false;
    port = 8081;
    address = bindAddr;
  };

  # BitTorrent port for clients
  networking.firewall.allowedTCPPorts = [ 6881 ];
  networking.firewall.allowedUDPPorts = [ 6881 ];

  # Firewall: Allow HAProxy gateway only
  # Managed centrally in reverse-proxy-backends.nix
}
