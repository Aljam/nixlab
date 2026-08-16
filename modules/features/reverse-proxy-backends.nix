# modules/features/reverse-proxy-backends.nix
# Central source of truth for proxy-only firewall rules
# All backend services should be bound to 127.0.0.1 and accessed via reverse proxy
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
  # Management subnet for admin interfaces
  managementSubnets = config.networking.subnets.management or [ "127.0.0.0/8" ];
in
{
  # Central firewall rules for reverse proxy backends
  # Individual services should NOT add their own extraInputRules for proxy access
  networking.firewall.extraInputRules = ''
    # ============================================
    # Reverse Proxy Backend Access Rules
    # All services bind to 127.0.0.1, proxy forwards requests
    # ============================================
    
    # Monitoring stack (Grafana, Prometheus, Alertmanager)
    ip saddr ${proxyIP} tcp dport 3000 accept  # Grafana
    ip saddr ${proxyIP} tcp dport 9090 accept  # Prometheus
    ip saddr ${proxyIP} tcp dport 9093 accept  # Alertmanager
    
    # *arr services
    ip saddr ${proxyIP} tcp dport 7878 accept  # Radarr
    ip saddr ${proxyIP} tcp dport 8989 accept  # Sonarr
    ip saddr ${proxyIP} tcp dport 9696 accept  # Prowlarr
    ip saddr ${proxyIP} tcp dport 8686 accept  # Lidarr
    ip saddr ${proxyIP} tcp dport 8787 accept  # Readarr
    
    # Media services
    ip saddr ${proxyIP} tcp dport 8096 accept  # Jellyfin
    ip saddr ${proxyIP} tcp dport 8080 accept  # qBittorrent WebUI
    ip saddr ${proxyIP} tcp dport 13700 accept # Autobrr
    
    # Other services
    ip saddr ${proxyIP} tcp dport 8000 accept  # Vaultwarden
    ip saddr ${proxyIP} tcp dport 32400 accept # Plex (if used)
    ip saddr ${proxyIP} tcp dport 8555 accept  # Homepage
    ip saddr ${proxyIP} tcp dport 9100 accept  # Node Exporter
    ip saddr ${proxyIP} tcp dport 8222 accept  # Syncthing
    
    # ============================================
    # Management subnet access (admin interfaces only)
    # ============================================
    ${lib.concatMapStringsSep "\n" (subnet: ''
      # PostgreSQL and pgAdmin: management subnet only
      ip saddr ${subnet} tcp dport 5432 accept
      ip saddr ${subnet} tcp dport 5050 accept
    '') managementSubnets}
  '';
}
