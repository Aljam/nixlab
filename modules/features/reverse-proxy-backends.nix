{ lib, subnets, ... }:

let
  # HAProxy runs on the pfSense gateway
  proxy = "${subnets.lan}.1";
  
  # LAN subnet for admin access
  lanSubnet = "${subnets.lan}.0/24";

  # Public-facing services (accessible via HAProxy)
  publicBackendPorts = [
    8096   # jellyfin
    8989   # sonarr
    7878   # radarr
    9696   # prowlarr
    6767   # bazarr
    8686   # lidarr
    8787   # readarr
    8111   # shoko
    5055   # jellyseerr
    13378  # audiobookshelf
    7474   # autobrr
    8222   # vaultwarden
    3000   # grafana
    8082   # homepage-dashboard
  ];
  
  # Sensitive services (HAProxy only, no LAN access)
  sensitivePorts = [
    8222   # vaultwarden - password manager
    3000   # grafana - monitoring dashboards
  ];
  
  # qBittorrent: WebUI should NEVER be publicly accessible
  # Only allow HAProxy to reach it (for Jackett/Prowlarr integration)
  qbittorrentPort = 8080;
in
{
  # Default firewall policy: deny all incoming (set in server-core.nix)
  
  networking.firewall.extraInputRules = ''
    # Allow HAProxy (pfSense gateway) to reach all backend services
    ip saddr ${proxy} tcp dport { ${lib.concatMapStringsSep ", " toString publicBackendPorts} } accept
    
    # Allow LAN subnet to access non-sensitive services for direct admin access
    # (optional - remove if you only want HAProxy access)
    ip saddr ${lanSubnet} tcp dport { 
      ${lib.concatMapStringsSep ", " toString (lib.filter (p: !(p ∈ sensitivePorts)) publicBackendPorts)} 
    } accept
    
    # qBittorrent: ONLY HAProxy can access (never expose to LAN directly)
    ip saddr ${proxy} tcp dport ${toString qbittorrentPort} accept
  '';
  
  # Log rejected packets for security auditing
  networking.firewall.logReject = true;
}
