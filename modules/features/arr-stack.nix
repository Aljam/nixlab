{ config, pkgs, lib, ... }:

{
  sops.defaultSopsFile = ../../../secrets/secrets.yaml;

  users.users.autobrr = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/autobrr";
    createHome = true;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  services.sonarr = {
    enable = true;
    user = "sonarr";
    group = "media";
  };

  services.radarr = {
    enable = true;
    user = "radarr";
    group = "media";
  };

  services.prowlarr = {
    enable = true;
  };
  
  users.users.prowlarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.seerr = {
    enable = true;
    port = 5055;
  };

  services.bazarr = {
    enable = true;
  };
  
  users.users.bazarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.recyclarr.enable = true;

  services.readarr = {
    enable = true;
  };
  
  users.users.readarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.lidarr = {
    enable = true;
    dataDir = "/var/lib/lidarr";
  };
  
  users.users.lidarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "0.0.0.0";
  };

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets.autobrr_api_key.path;
    settings = { 
      port = 7474;
      host = "0.0.0.0"; 
    };
  };
  
  systemd.services.autobrr.environment = {
    AUTOBRR_HOST = "0.0.0.0"; 
  };
}
