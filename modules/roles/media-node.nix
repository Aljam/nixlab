{ config, pkgs, ... }:

{
  imports = [
    ../features/jellyfin.nix
    ../features/arr-stack.nix
    ../features/torrents.nix
  ];

  # --- Dashboard UI ---
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    # Swapped the hardcoded 192.168.1.2 IP for localhost (127.0.0.1) for internal routing
    allowedHosts = "home.derezzed.info,127.0.0.1:8082";
    services = [
      {
        "Media & Requests" = [
          { Jellyfin = { href = "https://jellyfin.derezzed.info"; description = "Media Streaming"; icon = "jellyfin.png"; }; }
          { Seerr = { href = "https://seerr.derezzed.info"; description = "Media Requests"; icon = "seerr.png"; }; }
        ];
      }
      {
        "Automation & Downloads" = [
          { Sonarr = { href = "https://sonarr.derezzed.info"; description = "TV Shows"; icon = "sonarr.png"; }; }
          { Radarr = { href = "https://radarr.derezzed.info"; description = "Movies"; icon = "radarr.png"; }; }
          { Prowlarr = { href = "https://prowlarr.derezzed.info"; description = "Indexers"; icon = "prowlarr.png"; }; }
          # Using localhost instead of hardcoded IP so this works on any server
          { qBittorrent = { href = "http://127.0.0.1:8080"; description = "Torrents"; icon = "qbittorrent.png"; }; }
        ];
      }
      {
        "System & Monitoring" = [
          { Grafana = { href = "http://127.0.0.1:3000"; description = "Metrics & Dashboards"; icon = "grafana.png"; }; }
        ];
      }
    ];
  };
}
