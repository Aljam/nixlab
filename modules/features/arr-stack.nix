{ config, pkgs, lib, ... }:

{
  users.groups.media = {};

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

  sops.secrets."autobrr.env" = {
    sopsFile = ../../secrets/autobrr.enc.env;
    format = "dotenv";
    owner = "autobrr";
    group = "media";
  };

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

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.prowlarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.seerr = {
    enable = true;
    openFirewall = true;
    port = 5055;
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.bazarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.recyclarr.enable = true;

  services.readarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.readarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.lidarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/lidarr";
  };
  
  users.users.lidarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 13378;
    host = "0.0.0.0";
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
    AUTOBRR_HOST = "0.0.0.0"; 
  };
}
