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
          { Audiobookshelf = { href = "https://audiobookshelf.derezzed.info"; description = "Audiobooks & Podcasts"; icon = "audiobookshelf.png"; }; }
        ];
      }
      {
        "Automation & Downloads" = [
          { Sonarr = { href = "https://sonarr.derezzed.info"; description = "TV Shows"; icon = "sonarr.png"; }; }
          { Radarr = { href = "https://radarr.derezzed.info"; description = "Movies"; icon = "radarr.png"; }; }
          { Prowlarr = { href = "https://prowlarr.derezzed.info"; description = "Indexers"; icon = "prowlarr.png"; }; }
          { Bazarr = { href = "https://bazarr.derezzed.info"; description = "Subtitles Automation"; icon = "bazarr.png"; }; }
          { Readarr = { href = "https://readarr.derezzed.info"; description = "Books Automation"; icon = "readarr.png"; }; }
          { Lidarr = { href = "https://lidarr.derezzed.info"; description = "Music Automation"; icon = "lidarr.png"; }; }
          { qBittorrent = { href = "http://127.0.0.1:8080"; description = "Torrents"; icon = "qbittorrent.png"; }; }
          { Autobrr = { href = "https://autobrr.derezzed.info"; description = "IRC Torrent Filters"; icon = "autobrr.png"; }; }
        ];
      }
      {
        "System & Monitoring" = [
          { Grafana = { href = "https://grafana.derezzed.info"; description = "Metrics & Dashboards"; icon = "grafana.png"; }; }
        ];
      }
    ];
  };
}
