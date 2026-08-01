{ config, pkgs, ... }:

{
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
    port = 8989;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    port = 7878;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    port = 9696;
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    port = 5055;
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    port = 8080;
  };

  # --- Extended Media Library Stack ---
  services.bazarr = {
    enable = true;
    openFirewall = true;
    port = 6767;
  };

  services.readarr = {
    enable = true;
    openFirewall = true;
    port = 8787;
  };

  services.lidarr = {
    enable = true;
    openFirewall = true;
    port = 8686;
  };

  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 13378;
  };
  
  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets."autobrr.env".path;
    settings = { port = 7474; host = "0.0.0.0"; };
  };
  
  services.recyclarr.enable = true;
}
