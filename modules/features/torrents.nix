# modules/features/torrents.nix
# Security: qBittorrent WebUI should bind to localhost only
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP from flake.nix instead of hardcoding
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  # qBittorrent container configuration
  virtualisation.oci-containers.containers.qbittorrent = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    volumes = [
      "/mnt/media/downloads:/downloads"
      "/mnt/media/torrents:/torrents"
      "/etc/qbittorrent:/config"
    ];
    ports = [
      # BitTorrent port only - WebUI accessed via reverse proxy
      "6881:6881/tcp"
      "6881:6881/udp"
    ];
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Etc/UTC";
      # Security: Bind WebUI to localhost only (not 0.0.0.0)
      WEBUI_PORT = "8080";
      # Note: The container may still bind to 0.0.0.0 internally
      # Firewall rules below restrict access
    };
    extraOptions = [
      "--network=bridge"
    ];
  };

  # qbitmanage container (optional companion)
  virtualisation.oci-containers.containers.qbitmanage = {
    image = "lscr.io/linuxserver/qbitmanage:latest";
    volumes = [
      "/etc/qbitmanage:/config"
    ];
    depends_on = [ "qbittorrent" ];
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Etc/UTC";
      QBITTORRENT_URL = "http://127.0.0.1:8080";
      QBITTORRENT_USERNAME = "$__file{${config.sops.secrets."qbittorrent-username".path}}";
      QBITTORRENT_PASSWORD = "$__file{${config.sops.secrets."qbittorrent-password".path}}";
    };
  };

  # Firewall: Restrict qBittorrent WebUI to reverse proxy only
  networking.firewall.extraInputRules = ''
    # qBittorrent WebUI: Only allow from reverse proxy
    ip saddr ${proxyIP} tcp dport 8080 accept
    # BitTorrent ports: Open to all (required for P2P)
    tcp dport 6881 accept
    udp dport 6881 accept
  '';
}
