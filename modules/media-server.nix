{ config, pkgs, ... }:

{
  # --- Users, Groups & Directories ---
  users.groups.media = {};

  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  # --- Media Streaming (Jellyfin) ---
  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;
  services.jellyfin.group = "media";

  # Hardware acceleration passthrough for Jellyfin
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "media" "video" "render" ];
    DeviceAllow = [
      "/dev/nvidia0 rwm"
      "/dev/nvidiactl rwm"
      "/dev/nvidia-uvm rwm"
      "/dev/nvidia-uvm-tools rwm"
      "char-drm rwm"
    ];
  };

  # --- Automation & The Arr Stack ---
  services.sonarr = { enable = true; openFirewall = true; group = "media"; settings.server.bindAddress = "0.0.0.0"; };
  services.radarr = { enable = true; openFirewall = true; group = "media"; settings.server.bindAddress = "0.0.0.0"; };
  services.prowlarr = { enable = true; openFirewall = true; settings.server.bindAddress = "0.0.0.0"; };
  services.seerr = { enable = true; openFirewall = true; };
  
  services.autobrr = {
    enable = true;
    secretFile = "/etc/nixos/secrets/autobrr.env";
    settings = { port = 7474; host = "0.0.0.0"; };
  };
  
  services.recyclarr.enable = true;

  # --- Downloading & Container Management ---
  services.qbittorrent.enable = true;
  services.qbittorrent.openFirewall = true;
  services.qbittorrent.group = "media";

  virtualisation.oci-containers.containers.qbitmanage = {
    image = "ghcr.io/starbix/qbitmanage:latest";
    environment = {
      QBT_RUN = "true";
      QBT_SCHEDULE = "1440";
    };
    volumes = [
      "/var/lib/qbitmanage:/config"
      "/mnt/pool/media:/data/media"
      "/var/lib/qbittorrent:/qbittorrent"
    ];
  };

  # --- Dashboard UI ---
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "home.derezzed.info,192.168.1.2:8082";
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
          { qBittorrent = { href = "http://192.168.1.2:8080"; description = "Torrents"; icon = "qbittorrent.png"; }; }
        ];
      }
    ];
  };
}
