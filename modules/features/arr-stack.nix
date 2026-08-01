{ config, pkgs, ... }:

{
  # --- System Group & Users ---
  users.groups.media = {};
  
  users.users.autobrr = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/autobrr";
    createHome = true;
  };

  # Directory structures for media
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

# --- SOPS Secret for Autobrr ---
  sops.secrets."autobrr.env" = {
    sopsFile = ../../secrets/autobrr.enc.env;
    format = "dotenv";
    owner = "autobrr";
    group = "media";
  };

  # --- Core Video & Indexing Stack ---
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.seerr = {
    enable = true;
    openFirewall = true;
    port = 5055;
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8080;
  };

  # --- Extended Media Library Stack ---
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  services.readarr = {
    enable = true;
    openFirewall = true;
  };

  services.lidarr = {
    enable = true;
    openFirewall = true;
  };

  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 13378;
    host = 0.0.0.0
  };
  
  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets."autobrr.env".path;
    settings = { 
      port = 7474;
      host = "0.0.0.0"; 
    };
  };

  systemd.services.autobrr.environment = {
    AUTOBRR_HOST = "0.0.0.0"; # <-- Force it to listen externally
  };
  
  services.recyclarr.enable = true;
}
