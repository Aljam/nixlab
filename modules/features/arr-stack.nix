{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # SYSTEM GROUPS & USERS
  # ============================================================================
  users.groups.media = {};

  # Dedicated system user for Autobrr
  users.users.autobrr = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/autobrr";
    createHome = true;
  };

  # Declarative directory creation on the ZFS storage pool with strict permissions
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  # ============================================================================
  # SECRETS MANAGEMENT (SOPS)
  # ============================================================================
  sops.secrets."autobrr.env" = {
    sopsFile = ../../secrets/autobrr.enc.env;
    format = "dotenv";
    owner = "autobrr";
    group = "media";
  };

  # ============================================================================
  # CORE VIDEO & INDEXING SERVICES (THE ARR STACK)
  # ============================================================================

  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "sonarr";
    group = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "radarr";
    group = "media";
  };

  # Prowlarr manages its own user; we force its primary group to 'media'
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  users.users.prowlarr.group = lib.mkForce "media";

  services.seerr = {
    enable = true;
    openFirewall = true;
    port = 5055;
  };

  # Bazarr manages its own user; we force its primary group to 'media'
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
  users.users.bazarr.group = lib.mkForce "media";

  # ============================================================================
  # DOWNLOAD CLIENT & MANAGEMENT
  # ============================================================================

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8080;
  };

  services.recyclarr.enable = true;

  # ============================================================================
  # EXTENDED MEDIA LIBRARY (BOOKS, MUSIC, AUDIOBOOKS)
  # ============================================================================

  services.readarr = {
    enable = true;
    openFirewall = true;
    user = "readarr";
  };
  users.users.readarr.group = lib.mkForce "media";

  services.lidarr = {
    enable = true;
    openFirewall = true;
    user = "lidarr";
    dataDir = "/var/lib/lidarr";
  };
  users.users.lidarr.group = lib.mkForce "media";

  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 13378;
    host = "0.0.0.0";
  };

  # ============================================================================
  # AUTOMATION & RSS (AUTOBRR)
  # ============================================================================

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets."autobrr.env".path;
    settings = { 
      port = 7474;
      host = "0.0.0.0"; 
    };
  };

  systemd.services.autobrr.environment = {
    AUTOBRR_HOST = "0.0.0.0"; 
  };
}
