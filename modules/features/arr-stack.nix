{ config, pkgs, lib, ... }:

{
  sops.secrets.autobrr_api_key = {};

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
    openFirewall = true;
  };
  systemd.services.sonarr.environment.SONARR__SERVER__BINDADDRESS = "*";

  services.radarr = {
    enable = true;
    user = "radarr";
    group = "media";
    openFirewall = true;
  };
  systemd.services.radarr.environment.RADARR__SERVER__BINDADDRESS = "*";

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.prowlarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "*";

  services.seerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.bazarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.bazarr.environment.BAZARR__SERVER__BINDADDRESS = "*";

  services.recyclarr.enable = true;

  services.readarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.readarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.readarr.environment.READARR__SERVER__BINDADDRESS = "*";

  services.lidarr = {
    enable = true;
    dataDir = "/var/lib/lidarr";
    openFirewall = true;
  };
  
  users.users.lidarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.lidarr.environment.LIDARR__SERVER__BINDADDRESS = "*";

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
}{ config, pkgs, lib, ... }:

{
  sops.secrets.autobrr_api_key = {};

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
    openFirewall = true;
    settings.server.bindaddress = "*";
  };

  services.radarr = {
    enable = true;
    user = "radarr";
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings.server.bindaddress = "*";
  };
  
  users.users.prowlarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.seerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
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
    settings.server.bindaddress = "*";
  };
  
  users.users.readarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };

  services.lidarr = {
    enable = true;
    dataDir = "/var/lib/lidarr";
    openFirewall = true;
    settings.server.bindaddress = "*";
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
}
