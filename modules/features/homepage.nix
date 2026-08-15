{ config, pkgs, domains, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    # Binds to localhost to prevent HAProxy Host header validation errors
    allowedHosts = "home.${domains.primary}";
    
    services = [
      {
        "Media & Requests" = [
          { Jellyfin = { href = "https://jellyfin.${domains.primary}"; description = "Media Streaming"; icon = "jellyfin.png"; }; }
          { Seerr = { href = "https://seerr.${domains.primary}"; description = "Media Requests"; icon = "seerr.png"; }; }
          { Audiobookshelf = { href = "https://audiobookshelf.${domains.primary}"; description = "Audiobooks & Podcasts"; icon = "audiobookshelf.png"; }; }
        ];
      }
      {
        "Automation & Downloads" = [
          { Sonarr = { href = "https://sonarr.${domains.primary}"; description = "TV Shows"; icon = "sonarr.png"; }; }
          { Radarr = { href = "https://radarr.${domains.primary}"; description = "Movies"; icon = "radarr.png"; }; }
          { Prowlarr = { href = "https://prowlarr.${domains.primary}"; description = "Indexers"; icon = "prowlarr.png"; }; }
          { Bazarr = { href = "https://bazarr.${domains.primary}"; description = "Subtitles Automation"; icon = "bazarr.png"; }; }
          { Readarr = { href = "https://readarr.${domains.primary}"; description = "Books Automation"; icon = "readarr.png"; }; }
          { Lidarr = { href = "https://lidarr.${domains.primary}"; description = "Music Automation"; icon = "lidarr.png"; }; }
          { qBittorrent = { href = "https://qb.${domains.primary}"; description = "Torrents"; icon = "qbittorrent.png"; }; }
          { Autobrr = { href = "https://autobrr.${domains.primary}"; description = "IRC Torrent Filters"; icon = "autobrr.png"; }; }
          { Shoko = { href = "https://shoko.${domains.primary}"; description = "AniDB integration"; icon = "shoko.png"; }; }
        ];
      }
      {
        "System & Monitoring" = [
          { Grafana = { href = "https://grafana.${domains.primary}"; description = "Metrics & Dashboards"; icon = "grafana.png"; }; }
          { Pgadmin = { href = "https://db.${domains.primary}"; description = "Databases"; icon = "pgadmin.png"; }; }
        ];
      }
    ];
  };
}
