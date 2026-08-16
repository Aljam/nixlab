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

    # Allow proxy IP to reach backend services
    # Format: { port = <port>; addr = "<proxyIP>"; }
    allowProxyTo = [
      # Grafana
      { port = 3000; addr = proxyIP; }
      # Prometheus
      { port = 9090; addr = proxyIP; }
      # Alertmanager
      { port = 9093; addr = proxyIP; }
      # Vaultwarden (updated to 8222)
      { port = 8222; addr = proxyIP; }
      # Sonarr
      { port = 8989; addr = proxyIP; }
      # Radarr
      { port = 7878; addr = proxyIP; }
      # Prowlarr
      { port = 9696; addr = proxyIP; }
      # qBittorrent WebUI
      { port = 8080; addr = proxyIP; }
      # qBittorrent WebUI (qbweb)
      { port = 8081; addr = proxyIP; }
      # Syncthing
      { port = 8384; addr = proxyIP; }
    ];
  };
}
